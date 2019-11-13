
# frozen_string_literal: true

module InternshipOffersScopes
  # find internship with school_id or ignores those with a school id different
  module ByNotApplied
    extend ActiveSupport::Concern

    included do
      scope :ignore_already_applied, lambda { |user: |
        InternshipOffer.where
                       .not(id: InternshipOffer.joins(:internship_applications)
                                               .merge(InternshipApplication.where(user_id: user.id)))
      }
    end
  end
end
