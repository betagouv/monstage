module InternshipOffersScopes
  # find internships which had been bound by operators relationship
  module ByOperator
    extend ActiveSupport::Concern

    included do
      scope :by_operator, -> (user:) {
        InternshipOffer.joins(:internship_offer_operators)
                       .where(internship_offer_operators: {
                                operator_id: user.operator_id
                       })
      }
    end
  end
end
