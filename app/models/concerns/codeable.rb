module Codeable
  extend ActiveSupport::Concern
 
  included do
    validates :code, presence: true
    validates_uniqueness_of :code, case_sensitive: false
    before_validation :set_code, on: :create
  end
 
  def set_code
    self.code ||= loop do
      random_code = "#{self.class::CODEABLE[:prefix]}#{SecureRandom.hex(self.class::CODEABLE[:length]).upcase}"
      break random_code unless self.class.exists?(code: random_code)
    end
  end
end