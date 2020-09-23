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

  def self.build_from_internship_offer(internship_offer)
    Organisation.new(
      name: internship_offer.employer_name,
      street: internship_offer.street,
      zipcode: internship_offer.zipcode,
      city: internship_offer.city,
      website: internship_offer.employer_website,
      description: internship_offer.description,
      coordinates: internship_offer.coordinates,
      department: internship_offer.department,
      is_public: internship_offer.is_public,
      group_id: internship_offer.group_id,
    )
  end
end
