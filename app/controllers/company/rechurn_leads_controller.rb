class Company::RechurnLeadsController < Company::BaseController
  before_action :ensure_admin_access

  def index
    @projects = current_company.projects.order(:name)
    @statuses = Status.order(:name)
    @users = current_company.users.order(:name)
    
    # Get statistics
    @total_leads = current_company.leads.count
    @leads_by_status = current_company.leads.joins(:status).group('statuses.name').count
    @leads_by_user = current_company.leads.joins(:user).group('users.name').count
    
    # Apply filters if any
    @filtered_leads = apply_filters
    @filtered_count = @filtered_leads.count
  end

  def perform_rechurn
    # Get filter parameters
    filter_params = {
      project_ids: Array(params[:project_ids]).reject(&:blank?),
      status_ids: Array(params[:status_ids]).reject(&:blank?),
      user_ids: Array(params[:user_ids]).reject(&:blank?),
      created_at_from: params[:created_at_from],
      created_at_upto: params[:created_at_upto],
      max_rechurns: params[:max_rechurns]
    }
    @filtered_leads = apply_filters
    lead_count = params[:lead_count].to_i
    assign_user_id = params[:assign_user_id]
    assign_project_id = params[:assign_project_id]
    regenerate_checked = params[:regenerate_checked] == "1"
    
    # Validate required fields
    if lead_count <= 0
      flash[:alert] = "Number of leads to assign must be greater than 0."
      redirect_to company_rechurn_leads_path and return
    end
    
    if assign_user_id.blank?
      flash[:alert] = "Please select a user to assign leads to."
      redirect_to company_rechurn_leads_path and return
    end
    
    if regenerate_checked && assign_project_id.blank?
      flash[:alert] = "Please select a project when regenerate is checked."
      redirect_to company_rechurn_leads_path and return
    end
    @filtered_leads = @filtered_leads.limit(lead_count.to_i)
    updated_count = 0
    errors = []
    
    # Individual transactions per lead - if one fails, others continue
    if regenerate_checked
      @filtered_leads.each do |lead|
        new_lead = lead.company.leads.build(project_id: assign_project_id, user_id: assign_user_id, phone: lead.phone, email: lead.email, name: lead.name)
        if new_lead.save
          updated_count += 1
        else
          errors << "#{lead.name}: #{new_lead.errors.full_messages.join(', ')}"
        end
      end  
    else
      @filtered_leads.each do |lead|
        update_data = {}
        update_data[:user_id] = assign_user_id
        update_data[:project_id] = assign_project_id if regenerate_checked && assign_project_id.present?
        update_data[:churn_count] = (lead.churn_count.to_i + 1) if lead.comment.present?
        
        ActiveRecord::Base.transaction do
          # Delete call logs
          lead.call_logs.destroy_all
          
          # Update the lead
          if lead.update(update_data)
            updated_count += 1
          else
            errors << "#{lead.name}: #{lead.errors.full_messages.join(', ')}"
            raise ActiveRecord::Rollback  # Rolls back only THIS lead
          end
        end
      end
    end
    message_text = regenerate_checked ? "Regenerated" : "Rechurned"
    if updated_count > 0
      flash[:notice] = "Successfully #{message_text} #{updated_count} lead(s)."
      if errors.any?
        flash[:alert] = "Some leads couldn't be #{message_text}: #{errors.first(3).join('; ')}"
      end
    else
      flash[:alert] = "Error in entire operation. #{errors.first(3).join('; ')}"
    end
    
    redirect_to company_rechurn_leads_path
  end

  private

  def ensure_admin_access
    unless current_user.role.tag.in?(['admin'])
      redirect_to company_dashboard_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def apply_filters
    leads = current_company.leads.includes(:project, :status, :user)
    
    # Use the existing smart_search method for consistency
    search_params = {}
    
    # Project filter
    if params[:project_ids].present?
      project_ids = Array(params[:project_ids]).reject(&:blank?)
      search_params[:project_ids] = project_ids if project_ids.any?
    end
    
    # Status filter
    if params[:status_ids].present?
      status_ids = Array(params[:status_ids]).reject(&:blank?)
      search_params[:status_ids] = status_ids if status_ids.any?
    end
    
    # User filter
    if params[:user_ids].present?
      user_ids = Array(params[:user_ids]).reject(&:blank?)
      search_params[:user_ids] = user_ids if user_ids.any?
    end
    
    # Date range filter
    search_params[:created_at_from] = params[:created_at_from] if params[:created_at_from].present?
    search_params[:created_at_upto] = params[:created_at_upto] if params[:created_at_upto].present?
    
    # Max rechurns filter
    search_params[:max_rechurns] = params[:max_rechurns] if params[:max_rechurns].present?
    
    # Apply smart_search if any filters are present
    if search_params.any?
      leads.smart_search(search_params)
    else
      leads
    end
  end
end

