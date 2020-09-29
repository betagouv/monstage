class Organisation < ApplicationRecord
  DESCRIPTION_MAX_CHAR_COUNT = 500

  # queries
  include Nearbyable
  include Zipcodable

  # utils
  include Discard::Model
  include PgSearch::Model

  # Relations
  belongs_to :group, optional: true
  belongs_to :employer, class_name: 'User'

  # Validations
  validates :name, :street, :zipcode, :city, presence: true
  validates :description, length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

  has_rich_text :description_rich_text

  before_validation :replicate_rich_text_to_raw_fields


  def anonymize
    fields_to_reset = {
      name: 'NA',
      street: 'NA',
      zipcode: 'NA',
      city: 'NA',
      description: 'NA'
    }
    update(fields_to_reset)
    discard
  end

  def replicate_rich_text_to_raw_fields
    self.description = description_rich_text.to_plain_text if description_rich_text.to_s.present?
  end
end
