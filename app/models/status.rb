class Status < ApplicationRecord
	include Nameable
	has_many :leads, dependent: :restrict_with_error
	has_many :call_logs, class_name: 'Leads::CallLog', dependent: :restrict_with_error
end
