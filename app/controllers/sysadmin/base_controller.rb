class Sysadmin::BaseController < ApplicationController
  layout 'sysadmin'
  before_action :ensure_sysadmin

  protected

  def ensure_sysadmin
    unless current_user&.sysadmin?
      flash[:alert] = "Access denied. You don't have permission to access this area."
      redirect_to root_path
    end
  end
end
