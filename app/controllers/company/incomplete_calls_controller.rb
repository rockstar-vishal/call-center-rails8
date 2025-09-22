class Company::IncompleteCallsController < Company::BaseController
  before_action :set_call_logs
  before_action :set_call_log, only: [:show, :edit, :update, :destroy]
  before_action :ensure_not_admin, only: [:edit, :update]

  def index
    @call_logs = @call_logs.includes(:lead, :user, :status).order(created_at: :desc)
  end

  def show
    @lead = @call_log.lead
  end

  def edit
    @statuses = Status.order(:name)
  end

  def update
    if @call_log.update(call_log_params)
      flash[:notice] = 'Call log was successfully updated.'
      redirect_to company_incomplete_calls_path
    else
      @statuses = Status.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.admin?
      flash[:alert] = "Access denied. Only admins can delete call logs."
      redirect_to company_incomplete_calls_path and return
    end

    if @call_log.destroy
      flash[:notice] = 'Incomplete call log was successfully deleted.'
    else
      flash[:alert] = "Cannot delete this call log. #{@call_log.errors.full_messages.join(', ')}"
    end
    redirect_to company_incomplete_calls_path
  end

  private

  def set_call_logs
    @call_logs = Leads::CallLog.joins(lead: :company)
                   .where(leads: { company: current_company })
                   .incomplete
    unless current_user.role&.tag == "admin"
      @call_logs = @call_logs.where(user_id: current_user.manageables.ids)
    end
  end

  def set_call_log
    @call_log = @call_logs.find(params[:id])
  end

  def call_log_params
    params.require(:leads_call_log).permit(:status_id, :ncd, :comment)
  end

  def ensure_not_admin
    if current_user.admin?
      flash[:alert] = "Access denied. Admins cannot update call logs - only delete them."
      redirect_to company_incomplete_calls_path
    end
  end
end
