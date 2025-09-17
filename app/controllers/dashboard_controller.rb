class DashboardController < ApplicationController
  def index
    if current_user.sysadmin?
      redirect_to sysadmin_dashboard_path
    elsif current_user.company_level_user?
      redirect_to company_dashboard_path
    else
      # Handle case where user doesn't have a proper role
      flash[:alert] = "Your account doesn't have proper permissions. Please contact your administrator."
      sign_out current_user
      redirect_to new_user_session_path
    end
  end
end
