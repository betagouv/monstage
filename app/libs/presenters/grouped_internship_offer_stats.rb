# frozen_string_literal: true

module Presenters
  class GroupedInternshipOfferStats
    delegate :total_report_count,
             :total_applications_count,
             :total_male_applications_count,
             :total_female_applications_count,
             :approved_applications_count,
             :total_male_approved_applications_count,
             :total_female_approved_applications_count,
             :total_custom_track_approved_applications_count,
             to: :internship_offer

    attr_reader :internship_offer
    def initialize(internship_offer)
      @internship_offer = internship_offer
    end
  end
end
