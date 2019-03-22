module NearbyIntershipOffersQueryable
  extend ActiveSupport::Concern

  included do
    delegate :coordinates,
             to: :school, allow_nil: true

    scope :targeted_internship_offers, -> (user:) {
      query = InternshipOffer.kept
      query = query.merge(internship_offers_nearby_from_school(user: user)) if user.school
      query = query.merge(internship_offers_overlaping_school_weeks(user: user)) if user.school
      query
    }

    scope :internship_offers_nearby_from_school, -> (user:) {
      InternshipOffer.nearby(latitude: user.coordinates.latitude,
                             longitude: user.coordinates.longitude)
    }

    scope :internship_offers_overlaping_school_weeks, -> (user:) {
      InternshipOffer.by_weeks(weeks: user.school.weeks)
    }
  end
end
