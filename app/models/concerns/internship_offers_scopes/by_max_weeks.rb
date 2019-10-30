# frozen_string_literal: true

module InternshipOffersScopes
  module ByMaxWeeks
    extend ActiveSupport::Concern

    included do
      scope :ignore_max_internship_offer_weeks_reached, lambda {
        InternshipOffer.where('internship_offer_weeks_count > blocked_weeks_count')
      }
    end
  end
end
