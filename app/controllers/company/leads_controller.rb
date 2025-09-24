class Company::LeadsController < Company::BaseController
  before_action :set_leads
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :call, :submit_call]
  before_action :set_call_log, only: [:submit_call]
  before_action :check_admin, only: [:edit, :update, :destroy, :bulk_update]
  PER_PAGE = 50

  def index
    search_params = extract_search_params
    @leads = @leads.includes(:project, :status, :user)
    
    # Handle quick search
    if params[:quick_search].present?
      @leads = @leads.quick_search(params[:quick_search])
      @search_active = true
      @quick_search_query = params[:quick_search]
    elsif search_params.any?
      @leads = @leads.smart_search(search_params)
      @search_active = search_params.any?
    end
    
    @leads = @leads.order("leads.ncd asc nulls first, leads.created_at desc").page(params[:page]).per(PER_PAGE)
  end

  def show
    @call_logs = @lead.call_logs.includes(:user, :status).order(created_at: :desc)
    
    respond_to do |format|
      format.html { render layout: false if request.xhr? }
      format.json { render json: @lead }
    end
  end

  def new
    @lead = @leads.build
    @projects = current_company.projects.order(:name)
    @statuses = Status.order(:name)
    @users = current_user.manageables.order(:name)
  end

  def create
    @lead = @leads.build(lead_params)
    
    if @lead.save
      # Broadcast the new lead via Action Cable
      LeadsChannel.broadcast_lead_creation(@lead)
      
      flash[:notice] = 'Lead was successfully created.'
      redirect_to company_lead_path(@lead)
    else
      @projects = current_company.projects.order(:name)
      @statuses = Status.order(:name)
      @users = current_company.users.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @projects = current_company.projects.order(:name)
    @statuses = Status.order(:name)
    @users = current_company.users.order(:name)
  end

  def call
    @call_log = @lead.call_logs.build(user_id: current_user.id)
    
    respond_to do |format|
      if @call_log.save
        @statuses = Status.order(:name)
        format.html { render :call }
        format.turbo_stream # Will render call.turbo_stream.erb
      else
        @error_message = "Failed to Initiate Call: #{@call_log.errors.full_messages.join(', ')}"
        format.html do
          flash[:alert] = @error_message
          redirect_to (request.referer || company_leads_path)
        end
        format.turbo_stream # Will render call.turbo_stream.erb with error
      end
    end
  end

  def submit_call
    if @call_log_error
      # Handle invalid call log error
      respond_to do |format|
        format.html { render :call, layout: false, status: :unprocessable_entity }
        format.turbo_stream { render :call }
        format.json { render json: { success: false, errors: [@call_log_error] } }
      end
    elsif @call_log&.update(call_log_params)
      @redirect_url = request.referer || company_leads_path
      # Reload the lead to get fresh data after call log update
      @lead.reload
      
      # Broadcast the lead update via Action Cable
      LeadsChannel.broadcast_lead_update(@lead)
      
      respond_to do |format|
        format.html { redirect_to @redirect_url, notice: 'Call logged successfully.' }
        format.turbo_stream # Will render submit_call.turbo_stream.erb
        format.json { render json: { success: true, message: 'Call logged successfully' } }
      end
    else
      @statuses = Status.order(:name)
      respond_to do |format|
        format.html { render :call, layout: false, status: :unprocessable_entity }
        format.turbo_stream { render :call }
        format.json { render json: { success: false, errors: @call_log&.errors&.full_messages || ['Invalid call log'] } }
      end
    end
  end

  def update
    if @lead.update(lead_params)
      # Broadcast the lead update via Action Cable
      LeadsChannel.broadcast_lead_update(@lead)
      
      flash[:notice] = 'Lead was successfully updated.'
      redirect_to company_lead_path(@lead)
    else
      @projects = current_company.projects.order(:name)
      @statuses = Status.order(:name)
      @users = current_company.users.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @lead.destroy
      flash[:notice] = 'Lead was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this lead. #{@lead.errors.full_messages.join(', ')}"
    end
    redirect_to request.referer || company_leads_path
  end

  def bulk_update

    lead_ids = params[:lead_ids]
    
    if lead_ids.blank?
      flash[:alert] = "No leads selected for bulk update."
      redirect_to request.referer || company_leads_path and return
    end

    # Get accessible leads for the current user
    accessible_leads = @leads.where(id: lead_ids)
    
    if accessible_leads.empty?
      flash[:alert] = "No valid leads found for bulk update."
      redirect_to request.referer || company_leads_path and return
    end

    update_params = bulk_update_params
    updated_count = 0
    errors = []

    accessible_leads.each do |lead|
      # Only update fields that are provided
      update_data = {}
      update_data[:status_id] = update_params[:status_id] if update_params[:status_id].present?
      update_data[:user_id] = update_params[:user_id] if update_params[:user_id].present?
      
      # Handle deletion checkboxes
      update_data[:ncd] = nil if update_params[:delete_ncd] == "1"
      
      if update_data.any? || update_params[:delete_comments] == "1"
        # Use transaction to ensure data integrity
        ActiveRecord::Base.transaction do
          # Handle comment deletion within transaction
          if update_params[:delete_comments] == "1"
            update_data[:churn_count] = (lead.churn_count.to_i + 1) if lead.comment.present?
            update_data[:comment] = nil
            # Delete all call logs for this lead
            lead.call_logs.destroy_all
          end
          
          # Update the lead
          if lead.update(update_data)
            updated_count += 1
          else
            errors << "#{lead.name}: #{lead.errors.full_messages.join(', ')}"
            raise ActiveRecord::Rollback
          end
        end
      end
    end

    if updated_count > 0
      flash[:notice] = "Successfully updated #{updated_count} lead(s)."
      if errors.any?
        flash[:alert] = "Some leads couldn't be updated: #{errors.first(3).join('; ')}"
      end
    else
      flash[:alert] = "No leads were updated. #{errors.first(5).join('; ')}"
    end

    redirect_to request.referer || company_leads_path
  end

  private

  def check_admin
    unless current_user.admin?
      flash[:alert] = "You are not authorized to update leads directly. This incident has been reported!"
      redirect_to company_leads_path and return
    end
  end

  def set_lead
    begin
      @lead = @leads.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      # If lead is not accessible through normal means, check if user has call logs for this lead
      # This allows viewing leads in reports even if they're not currently accessible
      if current_user.call_logs.exists?(lead_id: params[:id])
        @lead = current_company.leads.find(params[:id])
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def set_leads
    @leads = Lead.accessible_by(current_user)
  end

  def set_call_log
    # Get the call log ID from params
    if params[:call_log_id]
      begin
        @call_log = @lead.call_logs.find(params[:call_log_id])
      rescue ActiveRecord::RecordNotFound
        @call_log = nil
        @call_log_error = "Invalid call log entry. Please start a new call."
      end
    end
  end

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :project_id, :status_id, :user_id, :comment, :ncd)
  end


  def call_log_params
    params.require(:leads_call_log).permit(:status_id, :ncd, :comment)
  end

  def bulk_update_params
    params.permit(:status_id, :user_id, :delete_ncd, :delete_comments)
  end

  def extract_search_params
    search_params = {}
    
    # Text search parameters
    search_params[:name] = params[:search_name] if params[:search_name].present?
    search_params[:email] = params[:search_email] if params[:search_email].present?
    search_params[:phone] = params[:search_phone] if params[:search_phone].present?
    search_params[:comment] = params[:search_comment] if params[:search_comment].present?
    search_params[:max_rechurns] = params[:search_max_rechurns] if params[:search_max_rechurns].present?
    search_params[:code] = params[:search_code] if params[:search_code].present?
    # Array parameters (multiselect)
    search_params[:status_ids] = params[:search_status_ids] if params[:search_status_ids].present?
    search_params[:project_ids] = params[:search_project_ids] if params[:search_project_ids].present?
    search_params[:user_ids] = params[:search_user_ids] if params[:search_user_ids].present?
    
    # Date range parameters
    search_params[:ncd_from] = params[:search_ncd_from] if params[:search_ncd_from].present?
    search_params[:ncd_upto] = params[:search_ncd_upto] if params[:search_ncd_upto].present?
    
    search_params
  end
end
