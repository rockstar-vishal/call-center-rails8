class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include ::Codeable
  CODEABLE = {prefix: "US", length: 4}
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  belongs_to :company
  belongs_to :role
  
  # Manager relationships
  has_many :user_managers, dependent: :destroy
  has_many :managers, through: :user_managers, source: :manager

  has_many :leads, dependent: :restrict_with_error
  has_many :call_logs, class_name: "::Leads::CallLog"
  
  has_many :managed_user_relationships, class_name: 'UserManager', foreign_key: 'manager_id', dependent: :destroy
  has_many :subordinates, through: :managed_user_relationships, source: :user

  validates :email, presence: true

  # Role checking methods
  def sysadmin?
    role.tag == 'sysad'
  end

  def manageables
    users = self.company.users
    return users if self.admin?
    return users.where(id: self.subordinates.ids | [self.id])
  end

  def company_level_user?
    %w[admin manager executive].include?(role.tag)
  end

  def admin?
    role.tag == 'admin'
  end

  def manager?
    role.tag == 'manager'
  end

  def executive?
    role.tag == 'executive'
  end

  # Lead visibility methods
  def accessible_leads
    Lead.accessible_by(self)
  end

  def can_access_lead?(lead)
    accessible_leads.exists?(id: lead.id)
  end

  # Get all subordinates recursively (for complex hierarchies)
  def all_subordinates
    direct_subordinates = subordinates.to_a
    all_subs = direct_subordinates.dup
    
    direct_subordinates.each do |subordinate|
      all_subs += subordinate.all_subordinates
    end
    
    all_subs.uniq
  end
end
