class Company::ReportsController < Company::BaseController
	before_action :ensure_manager_or_admin_access
	before_action :set_leads
	before_action :set_created_start_end, only: [:projects]
	
	# Helper method for smart search - can be overridden in individual report methods
	def apply_smart_search_filters(leads = @leads)
		leads = leads.where(project_id: params[:project_ids]) if params[:project_ids].present?
		leads = leads.where(status_id: params[:status_ids]) if params[:status_ids].present?
		leads = leads.where(user_id: params[:user_ids]) if params[:user_ids].present?
		leads = leads.where(created_at: @start_date..@end_date) if @start_date && @end_date
		leads
	end

	def projects
		# Apply smart search filters
		@filtered_leads = apply_smart_search_filters(@leads)
		
		# Generate report data
		@data = @filtered_leads.group("project_id, status_id").select("project_id, status_id, COUNT(*)").as_json(except: [:id])
		@statuses = Status.where(id: @data.map{|k| k["status_id"]}.uniq)
		@projects = current_user.company.projects.where(id: @data.map{|k| k["project_id"]}.uniq)
		
		# Set result count for display
		@result_count = @filtered_leads.count
	end

	def productivity

	end

	def activity

	end

	def users


	end

	def performance
		

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

	def set_created_start_end
		@start_date = params[:created_at_from].present? ? Date.parse(params[:created_at_from]) : (Date.today - 7.days)
		@end_date = params[:created_at_upto].present? ? Date.parse(params[:created_at_upto]) : Date.today
		@start_date = @start_date.beginning_of_day
		@end_date = @end_date.end_of_day
	end
end