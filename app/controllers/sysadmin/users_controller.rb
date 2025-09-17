class Sysadmin::UsersController < Sysadmin::BaseController
  before_action :set_users
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = @users.includes(:company, :role).order(:name)
  end

  def show
  end

  def new
    @user = @users.new
    @companies = Company.all.order(:name)
    @roles = Role.where(tag: ["sysad", "admin"]).order(:name)
  end

  def create
    @user = @users.new(user_params)
    
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to sysadmin_user_path(@user)
    else
      @companies = Company.all.order(:name)
      @roles = Role.where(tag: ["sysad", "admin"]).order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @companies = Company.all.order(:name)
    @roles = Role.where(tag: ["sysad", "admin"]).order(:name)
  end

  def update
    if @user.update(user_params)
      flash[:notice] = 'User was successfully updated.'
      redirect_to sysadmin_user_path(@user)
    else
      @companies = Company.all.order(:name)
      @roles = Role.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:notice] = 'User was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this user. #{@user.errors.full_messages.join(', ')}"
    end
    redirect_to sysadmin_users_path
  end

  private

  def set_users
    @users = ::User.joins(:role).where(role: {tag: ["sysad","admin"]})
  end

  def set_user
    @user = @users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone, :company_id, :role_id, :password, :password_confirmation)
  end
end
