class Organisation < ApplicationRecord
  DESCRIPTION_MAX_CHAR_COUNT = 500
  
  # queries
  include FindableWeek
  include Nearbyable
  include Zipcodable

  # utils
  include Discard::Model
  include PgSearch::Model

  # Relations
  belongs_to :group, optional: true 
  
  # Validations
  validates :name, :street, :zipcode, :city, presence: true
  # validates :description, length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

  # has_rich_text :description

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
end
