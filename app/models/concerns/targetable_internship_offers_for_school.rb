# frozen_string_literal: true

module TargetableInternshipOffersForSchool
  extend ActiveSupport::Concern

  included do
    include InternshipOffersScopes::ByCoordinates
    include InternshipOffersScopes::BySchool
    include InternshipOffersScopes::ByWeeks
    include InternshipOffersScopes::ByMaxWeeks
    include InternshipOffersScopes::ByMaxCandidates
    include InternshipOffersScopes::ByNotApplied

    scope :targeted_internship_offers, lambda { |user:, coordinates:|
      query = InternshipOffer.kept
      coordinates ||= user.try(:school).try(:coordinates)
      query = query.merge(internship_offers_nearby(coordinates: coordinates)) if coordinates
      query = query.merge(internship_offers_overlaping_school_weeks(weeks: user.school.weeks)) if user.school
      query = query.merge(ignore_internship_restricted_to_other_schools(school_id: user.school_id))
      query = query.merge(ignore_max_candidates_reached)
      query = query.merge(ignore_max_occurence_reached)
      query = query.merge(ignore_already_applied(user: user)) if user.respond_to?(:internship_applications)
      query
    }
  end
end
