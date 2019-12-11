# frozen_string_literal: true

module Presenters
  class InternshipOfferStatsTotal
    def report_row_title
      'Total'
    end

    def total_report_count
      offers.sum(&:total_report_count)
    end

    def total_applications_count
      offers.sum(&:total_applications_count)
    end

    def total_male_applications_count
      offers.sum(&:total_male_applications_count)
    end

    def total_female_applications_count
      offers.sum(&:total_female_applications_count)
    end

    def approved_applications_count
      offers.sum(&:approved_applications_count)
    end

    def total_male_approved_applications_count
      offers.sum(&:total_male_approved_applications_count)
    end

    def total_female_approved_applications_count
      offers.sum(&:total_female_approved_applications_count)
    end

    def total_custom_track_approved_applications_count
      offers.sum(&:total_custom_track_approved_applications_count)
    end

    attr_reader :offers
    def initialize(offers:)
      @offers = offers
    end
  end
end
