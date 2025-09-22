class Leads::CallLog < ApplicationRecord
  belongs_to :lead
  belongs_to :user
  belongs_to :status, optional: true

  validate :comment_mandatory, on: :create
  validate :limited_attempts, on: :create

  scope :incomplete, -> {where(comment: [nil, ""])}

  ATTEMPT_LIMIT = 2

  def comment_mandatory
    if Leads::CallLog.where(lead_id: self.lead_id, user_id: self.user_id).incomplete.present?
      errors.add(:base, "Previous Call Not Completed")
    end
  end

  def limited_attempts
    if Leads::CallLog.where(user_id: self.user_id).incomplete.count >= ATTEMPT_LIMIT
      errors.add(:base, "You have too many incomplete calls in your bucket")
    end
  end
end
