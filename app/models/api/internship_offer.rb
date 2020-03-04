# frozen_string_literal: true

module Api
  class InternshipOffer < ApplicationRecord
    include Nearbyable
    include BaseInternshipOffer

    validates :remote_id,
              :permalink,
              presence: true

    validates :zipcode, zipcode: { country_code: :fr }
    validates :remote_id, uniqueness: { scope: :employer_id }

    after_initialize :init

    def init
      self.max_candidates ||= 1
      self.is_public ||= false
    end

    def formatted_coordinates
      {
        latitude: coordinates.latitude,
        longitude: coordinates.longitude
      }
    end

    def as_json(options={})
      super(options.merge(
        only: %i[title
                 description
                 employer_name
                 employer_description
                 employer_website
                 street
                 zipcode
                 city
                 remote_id
                 permalink
                 sector_uuid
                 max_candidates
                 published_at],
        methods: [:formatted_coordinates]
      ))
    end
  end
end
