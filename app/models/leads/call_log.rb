class Leads::CallLog < ApplicationRecord
  belongs_to :lead
  belongs_to :user
  belongs_to :status, optional: true

  validate :comment_mandatory, on: :create
  validate :limited_attempts, on: :create

  scope :incomplete, -> {where(comment: [nil, ""])}

  after_save :update_lead

  ATTEMPT_LIMIT = 2

  def update_lead
    self.lead.status_id = self.status_id if self.status.present?
    self.lead.ncd = self.ncd if self.ncd.present?
    if self.comment.present?
      self.lead.comment = "#{self.lead.comment} \n(#{self.user.name} @ #{Time.zone.now.strftime("%d-%b %I:%M %p")}) #{self.comment}"
    end
    
    unless self.lead.save
      # Add lead validation errors to call log errors
      self.lead.errors.full_messages.each do |message|
        self.errors.add(:base, "Lead update failed: #{message}")
      end
      # Prevent the call log from being saved
      throw :abort
    end
  end

  def comment_mandatory
    if Leads::CallLog.where(lead_id: self.lead_id, user_id: self.user_id).incomplete.present?
      errors.add(:base, "You already have an incomplete attempt on this lead")
    end
  end

  def limited_attempts
    if Leads::CallLog.where(user_id: self.user_id).incomplete.count >= ATTEMPT_LIMIT
      errors.add(:base, "You have too many incomplete calls in your bucket")
    end
  end
end
