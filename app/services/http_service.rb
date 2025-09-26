class HttpService
  def initialize(lead)
    @lead = lead
  end

  def migrate_hot_lead_to_crm
    begin
      uri = URI(build_url)
      payload = build_payload.to_json
      response = execute_post_https uri, payload
      handle_response(response)
    rescue => e
      log_error(e)
      false
    end
  end

  private

  def execute_post_https uri, payload
    require 'net/http'
    require 'uri'
    require 'json'
    
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.read_timeout = 30
    http.open_timeout = 30
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request.body = payload
    
    http.request(request)
  end

  def build_url
    @lead.company.crm_domain
  end

  def build_payload
    {
      name: @lead.name,
      mobile: @lead.phone,
      email: @lead.email,
      project_name: @lead.project&.name,
      telecaller_name: @lead.user&.name,
      assigned_to_email: @lead.user&.assignee_email
    }
  end

  def handle_response(response)
    if response.code.to_i.between?(200, 299)
      log_success(response.code)
      response_body = JSON.parse response.body
      lead_no = response_body["lead_no"]
      @lead.update_columns(:crm_created=>true, :crm_lead_no=>lead_no, :crm_response=>response.body)
      true
    elsif response.code.to_i.between?(500, 599)
      log_failure(response.code, "")
      @lead.update_columns(:crm_created=>false, :crm_response=>"Internal Server Error : #{response.code}")  
    else
      log_failure(response.code, response.body)
      @lead.update_columns(:crm_created=>false, :crm_response=>response.body)
      false
    end
  end

  def log_success(code)
    Rails.logger.info "CRM notification sent successfully for lead #{@lead.id}: #{code}"
  end

  def log_failure(code, body)
    Rails.logger.error "CRM notification failed for lead #{@lead.id}: #{code} - #{body}"
  end

  def log_error(error)
    Rails.logger.error "CRM notification error for lead #{@lead.id}: #{error.message}"
  end
end
