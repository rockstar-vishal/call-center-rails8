class Company::ReportsController < Company::BaseController
	before_action :ensure_manager_or_admin_access
	before_action :set_created_start_end, only: [:projects, :activity, :productivity, :details]
	before_action :set_call_logs, only: [:projects, :activity, :productivity, :details]

	def filter_call_logs logs
		logs = logs.where(user_id: params[:user_ids]) if params[:user_ids].present?
		logs = logs.joins(:lead).where(lead: {project_id: params[:project_ids]}) if params[:project_ids].present?
		logs = logs.where(status_id: params[:status_ids]) if params[:status_ids].present?
		logs = logs.where.not(comment: nil) if params[:comment_edited].present?
		logs = logs.where.not(status_id: nil) if params[:status_edited].present?
		logs = TimeRangeFilterService.new(logs, params[:time_range]).call
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

	def details
		@filtered_logs = filter_call_logs @call_logs
		# Set result count for display
		@result_count = @filtered_logs.count
	end

	def detail_path args=nil
		return company_reports_details_path(created_at_from: @start_date.to_date, created_at_upto: @end_date.to_date, user_ids: params[:user_ids], status_ids: params[:status_ids], project_ids: params[:project_ids], **args)
	end
	helper_method :detail_path

	private

	def ensure_manager_or_admin_access
		unless current_user.role.tag.in?(['manager', 'admin'])
			flash[:alert] = "You don't have permission to access reports."
			redirect_to company_dashboard_path
		end
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