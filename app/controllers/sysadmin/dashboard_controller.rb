class Sysadmin::DashboardController < Sysadmin::BaseController
  def index
    @companies_count = Company.count
    @users_count = User.count
    @leads_count = Lead.count
    @recent_companies = Company.order(created_at: :desc).limit(5)
    @recent_users = User.includes(:company, :role).order(created_at: :desc).limit(5)
  end
end
