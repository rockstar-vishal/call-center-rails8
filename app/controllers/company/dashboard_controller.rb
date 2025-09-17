class Company::DashboardController < Company::BaseController
  def index
    accessible_leads = Lead.accessible_by(current_user)
    @leads_count = accessible_leads.count
    @projects_count = current_company.projects.count
    @users_count = current_company.users.count
    @recent_leads = accessible_leads.includes(:project, :status, :user).order(created_at: :desc).limit(5)
    @recent_projects = current_company.projects.order(created_at: :desc).limit(5)
  end
end
