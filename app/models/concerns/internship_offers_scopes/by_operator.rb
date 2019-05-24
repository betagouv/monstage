# frozen_string_literal: true

module InternshipOffersScopes
  # find internships which had been bound by operators relationship
  # InternshipOffer.where(employer_id: user.id)
  module ByOperator
    extend ActiveSupport::Concern

    included do
      scope :mines_and_sumbmitted_to_operator, lambda { |user:|
        query = InternshipOffer.kept
        query = query.merge(
          InternshipOffer.left_joins(:internship_offer_operators)
                         .merge(
                           InternshipOffer.where(internship_offer_operators: {
                                                   operator_id: user.operator_id
                                                 }).or(InternshipOffer.where("internship_offers.employer_id = #{user.id}"))
                         )
        )
        query
      }
    end
  end
end
