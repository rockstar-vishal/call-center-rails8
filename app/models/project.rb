class Project < ApplicationRecord
  include ::Codeable
  CODEABLE = {prefix: "PR", length: 4}
  belongs_to :company
  has_many :leads, dependent: :restrict_with_error
  has_rich_text :reading_material
  
  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false, scope: :company
  validates :training_website_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :training_video, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  has_one_attached :training_doc

  # Validation for training document
  validate :training_doc_validation, if: -> { training_doc.attached? }

  def has_training_content?
    training_website_url.present? || training_video.present? || training_doc.attached? || reading_material.present?
  end

  private

  def training_doc_validation
    return unless training_doc.attached?

    acceptable_types = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
    unless acceptable_types.include?(training_doc.content_type)
      errors.add(:training_doc, 'must be a PDF or Word document only')
    end

    if training_doc.byte_size > 10.megabytes
      errors.add(:training_doc, 'must be less than 10MB')
    end
  end
end
