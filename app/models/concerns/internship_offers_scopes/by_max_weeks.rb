# frozen_string_literal: true

module InternshipOffersScopes
  # find internship offer weeks where max_occurence < internship_offer.blocked_weeks_count
  module ByMaxWeeks
    extend ActiveSupport::Concern

    included do
      scope :ignore_max_occurence_reached, lambda {
        InternshipOffer.where('max_occurence > blocked_weeks_count')
      }
    end
  end
end
