class Company::BaseController < ApplicationController
  layout 'company'
  before_action :ensure_company_user

  protected

  def ensure_company_user
    unless current_user&.company_level_user?
      flash[:alert] = "Access denied. You don't have permission to access this area."
      redirect_to root_path
    end
  end

  def current_company
    @current_company ||= current_user.company
  end
  helper_method :current_company
end
