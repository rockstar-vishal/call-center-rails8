class Sysadmin::RolesController < Sysadmin::BaseController
  before_action :set_role, only: [:show, :edit, :update, :destroy]

  def index
    @roles = Role.all.order(:name)
  end

  def show
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    
    if @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to sysadmin_role_path(@role)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @role.update(role_params)
      flash[:notice] = 'Role was successfully updated.'
      redirect_to sysadmin_role_path(@role)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @role.destroy
      flash[:notice] = 'Role was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this role. #{@role.errors.full_messages.join(', ')}"
    end
    redirect_to sysadmin_roles_path
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name, :tag)
  end
end
