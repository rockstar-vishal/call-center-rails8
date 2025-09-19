class Company::ReportsController < Company::BaseController
	before_action :set_leads
	before_action :set_created_start_end, only: [:projects]

	def projects
		@leads = @leads.where(created_at: @start_date..@end_date)
		@data = @leads.group("project_id, status_id").select("project_id, status_id, COUNT(*)").as_json(except: [:id])
		@statuses = Status.where(id: @data.map{|k| k["status_id"]}.uniq)
		@projects = current_user.company.projects.where(id: @data.map{|k| k["project_id"]}.uniq)
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

	def set_leads
		@leads = current_user.company.leads.accessible_by(current_user)
	end

	def set_created_start_end
		@start_date = Date.parse(params[:created_at_from])
		@end_date = Date.parse(params[:created_at_upto])
	end
end