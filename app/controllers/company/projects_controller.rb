class Company::ProjectsController < Company::BaseController
  before_action :set_projects
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = @projects.order(:name)
  end

  def show
    @leads_count = @project.leads.count
    @recent_leads = @project.leads.includes(:status, :user).order(created_at: :desc).limit(10)
  end

  def new
    @project = @projects.build
  end

  def create
    @project = @projects.build(project_params)
    
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to company_project_path(@project)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      flash[:notice] = 'Project was successfully updated.'
      redirect_to company_project_path(@project)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @project.destroy
      flash[:notice] = 'Project was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this project. #{@project.errors.full_messages.join(', ')}"
    end
    redirect_to company_projects_path
  end

  private

  def set_projects
    @projects = current_company.projects
  end

  def set_project
    @project = @projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name)
  end
end
