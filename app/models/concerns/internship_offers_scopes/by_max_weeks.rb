module InternshipOffersScopes
  # find internship offer weeks where max_internship_week_number < internship_offer.blocked_weeks_count
  module ByMaxWeeks
    extend ActiveSupport::Concern

    included do
      scope :ignore_max_internship_week_number_reached, -> () {
        InternshipOffer.where("max_internship_week_number > blocked_weeks_count")
      }
    end
  end
end
