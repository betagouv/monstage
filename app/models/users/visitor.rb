# frozen_string_literal: true

module Users
  class Visitor < User
    include InternshipOffersScopes::ByCoordinates
    def readonly?
      true
    end

    scope :targeted_internship_offers, -> (user:, coordinates:) {
      query = InternshipOffer.kept
      query = query.merge(InternshipOffer.published)
      query = query.merge(internship_offers_nearby(coordinates: coordinates)) if coordinates
      query
    }
  end
end
