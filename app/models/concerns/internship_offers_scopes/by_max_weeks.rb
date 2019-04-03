module InternshipOffersScopes
  # find internship offer weeks where max_weeks < internship_offer.blocked_weeks_count
  module ByMaxWeeks
    extend ActiveSupport::Concern

    included do
      scope :ignore_max_weeks_reached, -> () {
        InternshipOffer.where("max_weeks > blocked_weeks_count")
      }
    end
  end
end
