module InternshipOffersScopes
  # find internship in a 60km radious from user.school
  module Applicable
    extend ActiveSupport::Concern

    included do
      scope :applicable, -> () {
        InternshipOffer.joins(:internship_offer_weeks)
                       .where("internship_offer_weeks.blocked_applications_count < internship_offers.max_candidates")
      }
    end
  end
end
