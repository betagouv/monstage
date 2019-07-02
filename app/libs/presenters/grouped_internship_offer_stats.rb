# frozen_string_literal: true

module Presenters
  class GroupedInternshipOfferStats
    delegate :report_total_count,
             :total_applications_count,
             :total_male_applications_count,
             :total_female_applications_count,
             :total_convention_signed_applications_count,
             :total_male_convention_signed_applications_count,
             :total_female_convention_signed_applications_count,
             to: :internship_offer

    attr_reader :internship_offer
    def initialize(internship_offer)
      @internship_offer = internship_offer
    end
  end
end
