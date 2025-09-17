class Company::LeadsController < Company::BaseController
  before_action :set_leads
  before_action :set_lead, only: [:show, :edit, :update, :destroy]

  def index
    search_params = extract_search_params
    @leads = Lead.accessible_by(current_user).includes(:project, :status, :user)
    
    if search_params.any?
      @leads = @leads.smart_search(search_params)
    end
    
    @leads = @leads.order(created_at: :desc).page(params[:page]).per(25)
    @search_active = search_params.any?
  end

  def show
    @call_logs = @lead.call_logs.includes(:user, :status).order(created_at: :desc)
  end

  def new
    @lead = @leads.build
    @projects = current_company.projects.order(:name)
    @statuses = Status.order(:name)
    @users = current_company.users.order(:name)
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

  def destroy
    if @lead.destroy
      flash[:notice] = 'Lead was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this lead. #{@lead.errors.full_messages.join(', ')}"
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
