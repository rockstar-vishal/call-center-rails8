class Company < ApplicationRecord
	include Nameable
	validates :domain, presence: true
	has_many :users, dependent: :restrict_with_error
	has_many :leads, dependent: :restrict_with_error
	has_many :projects, dependent: :restrict_with_error

	# Logo and icon attachments
	has_one_attached :logo
	has_one_attached :icon

	# Validations for attachments
	validate :logo_validation, if: -> { logo.attached? }
	validate :icon_validation, if: -> { icon.attached? }

	def leads_remaining
		return Float::INFINITY unless lead_limit.present?
		[lead_limit - leads.count, 0].max
	end

	def lead_limit_reached?
		return false unless lead_limit.present?
		leads.count >= lead_limit
	end

	def lead_limit_percentage
		return 0 unless lead_limit.present?
		(leads.count.to_f / lead_limit * 100).round(1)
	end

	# Helper methods for logo and icon display
	def initials
		return 'CO' if name.blank?
		
		words = name.split(' ')
		if words.length >= 2
			"#{words.first.first}#{words.last.first}".upcase
		else
			name.first(2).upcase
		end
	end

	def display_logo_url
		logo.attached? ? Rails.application.routes.url_helpers.rails_blob_path(logo, only_path: true) : nil
	end

	def display_icon_url
		icon.attached? ? Rails.application.routes.url_helpers.rails_blob_path(icon, only_path: true) : nil
	end

	def has_logo?
		logo.attached?
	end

	def has_icon?
		icon.attached?
	end

	private

	def logo_validation
		return unless logo.attached?

		acceptable_types = ['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/svg+xml']
		unless acceptable_types.include?(logo.content_type)
			errors.add(:logo, 'must be a PNG, JPG, JPEG, GIF, or SVG file')
		end

		if logo.byte_size > 2.megabytes
			errors.add(:logo, 'must be less than 2MB')
		end
	end

	def icon_validation
		return unless icon.attached?

		acceptable_types = ['image/png', 'image/jpg', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/x-icon']
		unless acceptable_types.include?(icon.content_type)
			errors.add(:icon, 'must be a PNG, JPG, JPEG, GIF, SVG, or ICO file')
		end

		if icon.byte_size > 1.megabyte
			errors.add(:icon, 'must be less than 1MB')
		end
	end
end
