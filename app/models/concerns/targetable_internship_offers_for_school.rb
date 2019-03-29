module TargetableInternshipOffersForSchool
  extend ActiveSupport::Concern

  included do
    include InternshipOffersScopes::ByCoordinates
    include InternshipOffersScopes::BySchool
    include InternshipOffersScopes::ByWeeks
    include InternshipOffersScopes::Applicable

    scope :targeted_internship_offers, -> (user:) {
      query = InternshipOffer.kept
      query = query.merge(internship_offers_nearby_from_school(coordinates: user.school.coordinates)) if user.school
      query = query.merge(internship_offers_overlaping_school_weeks(weeks: user.school.weeks)) if user.school
      query = query.merge(ignore_internship_restricted_to_other_schools(school_id: user.school_id))
      query = query.merge(applicable)
      # raise query.to_sql
      query
    }
  end
end
