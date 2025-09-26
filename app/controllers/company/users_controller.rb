class Company::UsersController < Company::BaseController
  before_action :set_users
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :ensure_admin, except: [:index, :show]

  def index
    @users = @users.includes(:role).order(:name)
  end

  def show
  end

  def new
    @user = @users.build
    @roles = Role.where(tag: ['admin', 'manager', 'executive']).order(:name)
  end

  def create
    @user = @users.build(user_params)
    @user.password = 'password123' # Default password
    
    if @user.save
      flash[:notice] = 'User was successfully created with default password "password123".'
      redirect_to company_user_path(@user)
    else
      @roles = Role.where(tag: ['admin', 'manager', 'executive']).order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @roles = Role.where(tag: ['admin', 'manager', 'executive']).order(:name)
  end

  def update
    if @user.update(user_params)
      flash[:notice] = 'User was successfully updated.'
      redirect_to company_user_path(@user)
    else
      @roles = Role.where(tag: ['admin', 'manager', 'executive']).order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:notice] = 'User was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this user. #{@user.errors.full_messages.join(', ')}"
    end
    redirect_to company_users_path
  end

  private

  def set_users
    @users = current_company.users
  end

  def set_user
    @user = @users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :assignee_email, :role_id)
  end

  def ensure_admin
    unless current_user.admin?
      flash[:alert] = "Access denied. Only admins can manage users."
      redirect_to company_users_path
    end
  end
end
