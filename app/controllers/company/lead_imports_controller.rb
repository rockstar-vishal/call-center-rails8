require 'csv'

class Company::LeadImportsController < Company::BaseController
  def new
    # Show the import form
  end

  def create
    unless params[:file].present?
      flash[:alert] = "Please select a CSV file to import."
      redirect_to company_new_lead_import_path and return
    end

    file = params[:file]
    
    unless file.content_type == 'text/csv' || file.original_filename.end_with?('.csv')
      flash[:alert] = "Please upload a valid CSV file."
      redirect_to company_new_lead_import_path and return
    end

    # Check lead limit before processing
    if current_company.lead_limit.present?
      current_count = current_company.leads.count
      csv_row_count = CSV.read(file.path).length - 1 # Subtract header row
      
      if current_count + csv_row_count > current_company.lead_limit
        flash[:alert] = "Cannot import #{csv_row_count} leads. Company limit is #{current_company.lead_limit}, current count is #{current_count}. You can import maximum #{current_company.lead_limit - current_count} more leads."
        redirect_to company_new_lead_import_path and return
      end
    end

    begin
      import_results = process_csv_import(file)
      
      if import_results[:success_count] > 0
        flash[:notice] = "Successfully imported #{import_results[:success_count]} lead(s)."
        if import_results[:errors].any?
          flash[:alert] = "#{import_results[:error_count]} lead(s) failed to import. #{import_results[:errors].first(3).join(', ')}"
        end
      else
        flash[:alert] = "No leads were imported. #{import_results[:errors].first(5).join(', ')}"
      end
      
      redirect_to company_leads_path
    rescue CSV::MalformedCSVError
      flash[:alert] = "The uploaded file is not a valid CSV format."
      redirect_to company_new_lead_import_path
    rescue StandardError => e
      flash[:alert] = "An error occurred while processing the file: #{e.message}"
      redirect_to company_new_lead_import_path
    end
  end

  def sample
    # Generate and send sample CSV
    respond_to do |format|
      format.csv do
        csv_data = generate_sample_csv
        send_data csv_data, 
                  filename: "leads_import_sample.csv",
                  type: 'text/csv; charset=utf-8',
                  disposition: 'attachment'
      end
    end
  end

  private

  def process_csv_import(file)
    results = {
      success_count: 0,
      error_count: 0,
      errors: []
    }

    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
      begin
        lead_params = extract_lead_params(row)
        
        # Skip if lead with same email already exists
        if current_company.leads.exists?(email: lead_params[:email])
          results[:errors] << "Lead with email #{lead_params[:email]} already exists"
          results[:error_count] += 1
          next
        end

        lead = current_company.leads.build(lead_params)
        
        if lead.save
          results[:success_count] += 1
        else
          results[:errors] << "Row #{$.}: #{lead.errors.full_messages.join(', ')}"
          results[:error_count] += 1
        end
      rescue StandardError => e
        results[:errors] << "Row #{$.}: #{e.message}"
        results[:error_count] += 1
      end
    end

    results
  end

  def extract_lead_params(row)
    # Map CSV columns to lead attributes
    params = {}
    
    # Required fields
    params[:name] = row[:name] || row[:full_name]
    params[:email] = row[:email]
    params[:phone] = row[:phone] || row[:phone_number]
    
    # Optional fields
    params[:comment] = row[:comment] || row[:comments] || row[:notes]
    
    # Parse next call date
    if row[:next_call_date].present?
      begin
        params[:ncd] = DateTime.parse(row[:next_call_date].to_s)
      rescue ArgumentError
        # Invalid date format, skip
      end
    end
    
    # Find project by name
    if row[:project].present?
      project = current_company.projects.find_by(name: row[:project])
      params[:project_id] = project&.id
    end
    
    # Find status by name
    if row[:status].present?
      status = Status.find_by(name: row[:status])
      params[:status_id] = status&.id
    end
    
    # Find user by email
    if row[:assigned_to].present?
      user = current_company.users.find_by(email: row[:assigned_to])
      params[:user_id] = user&.id
    end
    
    # Remove nil values
    params.compact
  end

  def generate_sample_csv
    CSV.generate(headers: true) do |csv|
      # Add header row with humanized column names
      csv << [
        "Name",
        "Email", 
        "Phone Number",
        "Project",
        "Status", 
        "Assigned To",
        "Next Call Date",
        "Comments"
      ]
      
      # Add sample data rows
      csv << [
        "John Doe",
        "john.doe@example.com",
        "+1234567890",
        sample_project_name,
        sample_status_name,
        sample_user_email,
        "2024-12-25 10:00:00",
        "Interested in our services"
      ]
      
      csv << [
        "Jane Smith", 
        "jane.smith@example.com",
        "+1987654321",
        sample_project_name,
        sample_status_name,
        sample_user_email,
        "2024-12-26 14:30:00",
        "Follow up needed"
      ]
    end
  end

  def sample_project_name
    current_company.projects.first&.name || "Sample Project"
  end

  def sample_status_name
    Status.first&.name || "New"
  end

  def sample_user_email
    current_company.users.first&.email || "user@company.com"
  end
end
