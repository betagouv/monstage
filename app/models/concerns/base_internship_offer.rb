# frozen_string_literal: true

module BaseInternshipOffer
  extend ActiveSupport::Concern

  DESCRIPTION_MAX_CHAR_COUNT = 275
  OLD_DESCRIPTION_MAX_CHAR_COUNT = 715 # here for backward compatibility

  included do
    include Discard::Model

    validates :title,
              :employer_name,
              :zipcode,
              :city,
              presence: true

    validates :description, presence: true, length: { maximum: OLD_DESCRIPTION_MAX_CHAR_COUNT }
    validates :employer_description, length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

    validates :weeks, presence: true

    belongs_to :employer, polymorphic: true
    belongs_to :sector

    has_many :internship_offer_weeks, dependent: :destroy
    has_many :weeks, through: :internship_offer_weeks


    before_create :reverse_academy_by_zipcode

    def osm_url
      "http://www.openstreetmap.org/?mlat=#{coordinates.lat}&mlon=#{coordinates.lon}&zoom=12"
    end

    def formatted_autocomplete_address
      [
        street,
        city,
        zipcode
      ].compact.uniq.join(', ')
    end

    def reverse_academy_by_zipcode
      self.academy = Academy.lookup_by_zipcode(zipcode: zipcode)
    end


  end
end
