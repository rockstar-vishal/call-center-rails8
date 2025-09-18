class Company::LeadsController < Company::BaseController
  before_action :set_leads
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :mini_edit, :mini_update]
  PER_PAGE = 50

  def index
    search_params = extract_search_params
    @leads = @leads.includes(:project, :status, :user)
    
    if search_params.any?
      @leads = @leads.smart_search(search_params)
    end
    
    @leads = @leads.order(created_at: :desc).page(params[:page]).per(PER_PAGE)
    @search_active = search_params.any?
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

  def mini_edit
    @statuses = Status.order(:name)
    
    respond_to do |format|
      format.html { render layout: false if request.xhr? }
    end
  end

  def update
    if @lead.update(lead_params)
      flash[:notice] = 'Lead was successfully updated.'
      redirect_to company_lead_path(@lead)
    else
      @projects = current_company.projects.order(:name)
      @statuses = Status.order(:name)
      @users = current_company.users.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def mini_update
    if @lead.update(mini_lead_params)
      respond_to do |format|
        format.html { redirect_to company_leads_path, notice: 'Lead was successfully updated.' }
        format.json { render json: { success: true, message: 'Lead updated successfully' } }
      end
    else
      @statuses = Status.order(:name)
      respond_to do |format|
        format.html { render :mini_edit, layout: false, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @lead.errors.full_messages } }
      end
    end
  end

  def destroy
    unless current_user.admin?
      flash[:alert] = "You are not authorized to delete leads. This incident has been reported!"
      return
    end
    if @lead.destroy
      flash[:notice] = 'Lead was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this lead. #{@lead.errors.full_messages.join(', ')}"
    end
    redirect_to company_leads_path
  end

  def bulk_update
    unless current_user.admin?
      flash[:alert] = "Access denied. Only admins can perform bulk updates."
      redirect_to company_leads_path and return
    end

    lead_ids = params[:lead_ids]
    
    if lead_ids.blank?
      flash[:alert] = "No leads selected for bulk update."
      redirect_to company_leads_path and return
    end

    # Get accessible leads for the current user
    accessible_leads = @leads.where(id: lead_ids)
    
    if accessible_leads.empty?
      flash[:alert] = "No valid leads found for bulk update."
      redirect_to company_leads_path and return
    end

    update_params = bulk_update_params
    updated_count = 0
    errors = []

    accessible_leads.each do |lead|
      # Only update fields that are provided
      update_data = {}
      update_data[:status_id] = update_params[:status_id] if update_params[:status_id].present?
      update_data[:user_id] = update_params[:user_id] if update_params[:user_id].present?
      
      if update_data.any?
        if lead.update(update_data)
          updated_count += 1
        else
          errors << "#{lead.name}: #{lead.errors.full_messages.join(', ')}"
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

    redirect_to company_leads_path
  end

  private

  def set_lead
    @lead = @leads.find(params[:id])
  end

  def set_leads
    @leads = Lead.accessible_by(current_user)
  end

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, :project_id, :status_id, :user_id, :comment, :ncd)
  end

  def mini_lead_params
    params.require(:lead).permit(:status_id, :ncd, :comment)
  end

  def bulk_update_params
    params.permit(:status_id, :user_id)
  end

  def extract_search_params
    search_params = {}
    
    # Text search parameters
    search_params[:name] = params[:search_name] if params[:search_name].present?
    search_params[:email] = params[:search_email] if params[:search_email].present?
    search_params[:phone] = params[:search_phone] if params[:search_phone].present?
    search_params[:comment] = params[:search_comment] if params[:search_comment].present?
    
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
