class Organisation < ApplicationRecord
  DESCRIPTION_MAX_CHAR_COUNT = 500
  
  # queries
  include Listable
  include FindableWeek
  include Nearbyable
  include Zipcodable

  # utils
  include Discard::Model
  include PgSearch::Model
  
  # Validations
  validates :name, :street, :zipcode, :city, presence: true
  validates :description, presence: true,
                          length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

end
