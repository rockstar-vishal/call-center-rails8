class Leads::CallLog < ApplicationRecord
  belongs_to :lead
  belongs_to :user
  belongs_to :status, optional: true
end
