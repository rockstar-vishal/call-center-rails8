class Lead < ApplicationRecord
  include ::Codeable
  CODEABLE = {prefix: "LD", length: 4}
  belongs_to :company
  belongs_to :project
  belongs_to :status
  belongs_to :user
  has_many :call_logs, class_name: "Leads::CallLog", dependent: :destroy

  validates :phone, presence: true
  validate :company_lead_limit_not_exceeded, on: :create

  validate :phone_unique_for_company

  before_validation :set_defaults, on: :create

  before_update :set_user_assinged_on

  def set_defaults
    self.status_id = Status.find_by_tag("new")&.id if self.status_id.blank?
    self.project_id = self.company.projects.first&.id if self.company.projects.count == 1
    self.user_id = self.company.users.admins.first&.id if self.user_id.blank?
    self.user_assinged_on = Time.zone.now
    self.churn_count = 0
  end

  def phone_unique_for_company
    to_check_phone = self.phone.to_s.gsub(" ", "").last(10)
    leads = self.company.leads.where.not(id: self.id).where(project_id: self.project_id).where("RIGHT(REPLACE(leads.phone, ' ', ''), 10) = ?", to_check_phone)
    if leads.present?
      errors.add(:phone, "is taken - lead with this phone is already exits - #{leads.last.code}")
    end
  end

  def set_user_assinged_on
    if changes.keys.include?("user_id")
      self.user_assinged_on = Time.zone.now
    end
  end

  # Role-based filtering scope
  scope :accessible_by, ->(user) {
    case user.role.tag
    when 'admin'
      # Admins can see all company leads
      where(company: user.company)
    when 'manager'
      # Managers can see their own leads + subordinates' leads
      subordinate_ids = user.subordinates.pluck(:id)
      accessible_user_ids = [user.id] + subordinate_ids
      where(company: user.company, user_id: accessible_user_ids)
    when 'executive'
      # Executives can only see their own leads
      where(company: user.company, user_id: user.id)
    else
      # Default: no access
      none
    end
  }

  class << self
    # Alternative class method for API usage
    def for_user(user)
      accessible_by(user)
    end

    def quick_search(query)
      return all if query.blank?
      
      # Search across name, phone, and email fields
      sanitized_query = sanitize_sql_like(query.strip)
      where(
        "leads.name ILIKE ? OR leads.phone ILIKE ? OR leads.email ILIKE ?",
        "%#{sanitized_query}%", "%#{sanitized_query}%", "%#{sanitized_query}%"
      )
    end

    def smart_search(search_params)
      return all if search_params.blank?
      
      leads = all
      
      # Filter by status IDs
      if search_params[:status_ids].present?
        leads = leads.where(status_id: search_params[:status_ids])
      end
      
      # Filter by name (case-insensitive)
      if search_params[:name].present?
        leads = leads.where("leads.name ILIKE ?", "%#{sanitize_sql_like(search_params[:name])}%")
      end
      
      # Filter by email (case-insensitive)
      if search_params[:email].present?
        leads = leads.where("leads.email ILIKE ?", "%#{sanitize_sql_like(search_params[:email])}%")
      end

      if search_params[:code].present?
        leads = leads.where("leads.code ILIKE ?", "#{sanitize_sql_like(search_params[:code])}")
      end

      if search_params[:max_rechurns].present?
        leads = leads.where("leads.churn_count <= ?", search_params[:max_rechurns])
      end
      
      # Filter by phone (case-insensitive)
      if search_params[:phone].present?
        leads = leads.where("leads.phone ILIKE ?", "%#{sanitize_sql_like(search_params[:phone])}%")
      end
      
      # Filter by project IDs
      if search_params[:project_ids].present?
        leads = leads.where(project_id: search_params[:project_ids])
      end
      
      # Filter by next call date range (from)
      if search_params[:ncd_from].present?
        begin
          ncd_from = Time.zone.parse(search_params[:ncd_from])
          leads = leads.where("ncd >= ?", ncd_from)
        rescue ArgumentError
          # Invalid date format, skip this filter
        end
      end
      
      # Filter by next call date range (to)
      if search_params[:ncd_upto].present?
        begin
          ncd_upto = Time.zone.parse(search_params[:ncd_upto])
          leads = leads.where("ncd <= ?", ncd_upto)
        rescue ArgumentError
          # Invalid date format, skip this filter
        end
      end
      
      # Filter by assigned user IDs
      if search_params[:user_ids].present?
        leads = leads.where(user_id: search_params[:user_ids])
      end
      
      # Filter by comments (case-insensitive)
      if search_params[:comment].present?
        leads = leads.where("leads.comment ILIKE ?", "%#{sanitize_sql_like(search_params[:comment])}%")
      end
      
      leads
    end

    private

    def sanitize_sql_like(string)
      # Escape special characters in LIKE queries
      string.gsub(/[%_\\]/) { |match| "\\#{match}" }
    end
  end

  private

  def company_lead_limit_not_exceeded
    return unless company&.lead_limit.present?
    
    current_lead_count = company.leads.count
    
    if current_lead_count >= company.lead_limit
      errors.add(:base, "Company has reached its lead limit of #{company.lead_limit}. Cannot create more leads.")
    end
  end
end
