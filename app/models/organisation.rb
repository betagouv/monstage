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

  # @note some possible confusion, miss-understanding here
  #   1. Rich text was added after API
  #   2. API already exposed a "description" attributes (not rich text) [in/out]
  #     trying to upgrade description attribute was flacky
  #     because API returned description as an ActionText record.
  #   3. To avoid any circumvention (in/out) of the description
  #     we add a new description_rich_text element which is rendered when possiblee
  #   4. Bonus -> description will be used for description_tsv as template to extract keywords
  def replicate_rich_text_to_raw_fields
    self.description = description_rich_text.to_plain_text if description_rich_text.to_s.present?
  end
end
