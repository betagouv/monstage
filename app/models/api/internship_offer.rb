# frozen_string_literal: true

module Api
  class InternshipOffer < ApplicationRecord
    include Nearbyable

    validates :title,
              :employer_name,
              :zipcode,
              :city,
              :remote_id,
              :permalink,
              presence: true

    validates :group, inclusion: { in: Group::PUBLIC, message: 'Veuillez choisir une institution de tutelle' },
                      if: :is_public?

    validates :weeks, presence: true

    DESCRIPTION_MAX_CHAR_COUNT = 275
    OLD_DESCRIPTION_MAX_CHAR_COUNT = 715 # here for backward compatibility
    validates :description, presence: true, length: { maximum: OLD_DESCRIPTION_MAX_CHAR_COUNT }
    validates :employer_description, length: { maximum: DESCRIPTION_MAX_CHAR_COUNT }

    has_many :internship_offer_weeks, dependent: :destroy
    has_many :weeks, through: :internship_offer_weeks

    has_many :operators, through: :internship_offer_operators

    belongs_to :employer, polymorphic: true
    belongs_to :sector


    after_initialize :init
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

    def init
      self.max_candidates ||= 1
      self.max_internship_week_number ||= 1
      self.is_public = false
    end

    def reverse_academy_by_zipcode
      self.academy = Academy.lookup_by_zipcode(zipcode: zipcode)
    end
  end
end
