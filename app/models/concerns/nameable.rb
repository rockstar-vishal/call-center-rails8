module Nameable
  extend ActiveSupport::Concern
 
  included do
    validates :name, presence: true
    validates_uniqueness_of :name, case_sensitive: false
  end
end