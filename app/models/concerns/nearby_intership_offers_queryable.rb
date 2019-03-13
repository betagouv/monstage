module NearbyIntershipOffersQueryable
  extend ActiveSupport::Concern

  included do
    delegate :coordinates, to: :school, allow_nil: true

    scope :targeted_internship_offers, -> (user:) {
      return InternshipOffer.all unless user.coordinates
      InternshipOffer.nearby(latitude: user.coordinates.latitude,
                             longitude: user.coordinates.longitude)
    }
  end
end
