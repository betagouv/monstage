module InternshipOffersScopes
  # find internship offer weeks where blocked_applications_count < internship_offer.max_candiates
  module ByMaxCandidates
    extend ActiveSupport::Concern

    included do
      scope :ignore_max_candidates_reached, -> () {
        InternshipOffer.joins(:internship_offer_weeks)
                       .where("internship_offer_weeks.blocked_applications_count < internship_offers.max_candidates")
      }
    end
  end
end
