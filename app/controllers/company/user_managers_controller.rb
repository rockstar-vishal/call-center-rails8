class Company::UserManagersController < Company::BaseController
  before_action :set_user
  before_action :ensure_admin_or_manager

  def index
    @managers = @user.managers.includes(:role)
    @available_managers = current_company.users
                                        .joins(:role)
                                        .where(role: { tag: 'manager' })
                                        .where.not(id: [@user.id] + @user.managers.pluck(:id))
                                        .order(:name)
    @user_manager = UserManager.new
  end

  def create
    @user_manager = UserManager.new(user: @user, manager_id: params[:manager_id])
    
    if @user_manager.save
      flash[:notice] = 'Manager assigned successfully.'
    else
      flash[:alert] = "Could not assign manager: #{@user_manager.errors.full_messages.join(', ')}"
    end
    
    redirect_to company_user_managers_path(@user)
  end

  def destroy
    @user_manager = UserManager.find_by(user: @user, manager_id: params[:manager_id])
    
    if @user_manager&.destroy
      flash[:notice] = 'Manager removed successfully.'
    else
      flash[:alert] = 'Could not remove manager.'
    end
    
    redirect_to company_user_managers_path(@user)
  end

  private

  def set_user
    @user = current_company.users.find(params[:user_id])
  end

  def ensure_admin_or_manager
    unless current_user.admin? || current_user.manager?
      flash[:alert] = "Access denied. Only admins and managers can manage user assignments."
      redirect_to company_users_path
    end
  end
end
