class Role < ApplicationRecord
	include Nameable
	has_many :users, dependent: :restrict_with_error
end
