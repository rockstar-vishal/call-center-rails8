class Company::ReportsController < Company::BaseController
	before_action :ensure_manager_or_admin_access
	before_action :set_created_start_end, only: [:projects, :activity, :productivity]
	before_action :set_leads, only: []
	before_action :set_call_logs, only: [:projects, :activity, :productivity]
	
	# Helper method for smart search - can be overridden in individual report methods
	def apply_smart_search_filters(leads = @leads)
		leads = leads.where(project_id: params[:project_ids]) if params[:project_ids].present?
		leads = leads.where(status_id: params[:status_ids]) if params[:status_ids].present?
		leads = leads.where(user_id: params[:user_ids]) if params[:user_ids].present?
		leads = leads.where(created_at: @start_date..@end_date) if @start_date && @end_date
		leads
	end

	def filter_call_logs logs
		logs = logs.where(user_id: params[:user_ids]) if params[:user_ids].present?
		logs = logs.joins(:lead).where(lead: {project_id: params[:project_ids]}) if params[:project_ids].present?
		return logs
	end

	def projects
		# Apply smart search filters
		@filtered_logs = filter_call_logs @call_logs
		@filtered_logs = @filtered_logs.joins(:lead)
		uniq_project_ids = @filtered_logs.select("leads.project_id").as_json(except: [:id]).map{|k| k["project_id"]}.uniq
		@hot_status = Status.find_by_tag("hot")&.id
		@dead_status = Status.find_by_tag("dead")&.id
		@projects = current_company.projects.where(id: uniq_project_ids)
	end

	def activity
		@filtered_logs = filter_call_logs @call_logs
		uniq_user_ids = @filtered_logs.pluck(:user_id).uniq
		@users = current_user.manageables.where(id: uniq_user_ids)
	end

	def productivity
		@filtered_logs = filter_call_logs @call_logs
		
		# Get unique user IDs and fetch users
		uniq_user_ids = @filtered_logs.distinct.pluck(:user_id)
		@users = current_user.manageables.where(id: uniq_user_ids)
		
		# Use service to calculate productivity data
		service = ProductivityReportService.new(@filtered_logs, @users)
		result = service.call
		
		@productivity_data = result[:productivity_data]
		@totals = result[:totals]
		@result_count = result[:result_count]
	end

	private

	def ensure_manager_or_admin_access
		unless current_user.role.tag.in?(['manager', 'admin'])
			flash[:alert] = "You don't have permission to access reports."
			redirect_to company_dashboard_path
		end
	end

	def set_leads
		@leads = current_user.company.leads.accessible_by(current_user)
	end

	def set_call_logs
		@call_logs = current_company.call_logs
		unless current_user.admin?
			@call_logs = @call_logs.where(user_id: current_user.manageables)
		end
		@call_logs = @call_logs.where(created_at: @start_date..@end_date)
	end

	def set_created_start_end
		@start_date = params[:created_at_from].present? ? Date.parse(params[:created_at_from]) : (Date.today - 7.days)
		@end_date = params[:created_at_upto].present? ? Date.parse(params[:created_at_upto]) : Date.today
		@start_date = @start_date.beginning_of_day
		@end_date = @end_date.end_of_day
		@hot_status = Status.find_by_tag("hot")&.id
		@dead_status = Status.find_by_tag("dead")&.id
	end

end