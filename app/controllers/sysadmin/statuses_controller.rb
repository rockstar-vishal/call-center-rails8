class Sysadmin::StatusesController < Sysadmin::BaseController
  before_action :set_status, only: [:show, :edit, :update, :destroy]

  def index
    @statuses = Status.all.order(:name)
  end

  def show
  end

  def new
    @status = Status.new
  end

  def create
    @status = Status.new(status_params)
    
    if @status.save
      flash[:notice] = 'Status was successfully created.'
      redirect_to sysadmin_status_path(@status)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @status.update(status_params)
      flash[:notice] = 'Status was successfully updated.'
      redirect_to sysadmin_status_path(@status)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @status.destroy
      flash[:notice] = 'Status was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this status. #{@status.errors.full_messages.join(', ')}"
    end
    redirect_to sysadmin_statuses_path
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end

  def status_params
    params.require(:status).permit(:name, :tag)
  end
end
