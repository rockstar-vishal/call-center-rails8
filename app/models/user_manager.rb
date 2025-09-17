class UserManager < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: 'User'

  # Validation to prevent recursion
  validate :prevent_recursion
  validate :same_company_check
  validate :manager_role_check

  private

  def prevent_recursion
    return unless user_id && manager_id

    # Check if this would create a circular management chain
    if would_create_cycle?(user_id, manager_id)
      errors.add(:manager, "would create a circular management chain")
    end
  end

  def same_company_check
    return unless user && manager

    if user.company_id != manager.company_id
      errors.add(:manager, "must be from the same company")
    end
  end

  def manager_role_check
    return unless manager

    unless manager.role.tag == 'manager'
      errors.add(:manager, "must have manager role")
    end
  end

  def would_create_cycle?(user_id, manager_id, visited = Set.new)
    return true if visited.include?(user_id)
    return false if user_id == manager_id

    visited.add(user_id)

    # Check if the proposed manager has this user as their manager (direct or indirect)
    manager_relationships = UserManager.where(user_id: manager_id).pluck(:manager_id)
    
    manager_relationships.each do |potential_manager_id|
      return true if potential_manager_id == user_id
      return true if would_create_cycle?(potential_manager_id, user_id, visited.dup)
    end

    false
  end
end
