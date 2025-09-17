class Project < ApplicationRecord
  belongs_to :company
  has_many :leads, dependent: :restrict_with_error
  
  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false, scope: :company
end
