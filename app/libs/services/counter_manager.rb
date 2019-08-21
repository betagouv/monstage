# frozen_string_literal: true

# Services::CounterManager.reset_internship_offer_counters
module Services
  class CounterManager
    def self.reset_internship_offer_counters
      InternshipOffer.update_all(
        blocked_weeks_count: 0,
        total_applications_count: 0,
        convention_signed_applications_count: 0,
        approved_applications_count: 0,
        total_male_applications_count: 0,
        total_male_convention_signed_applications_count: 0,
        total_custom_track_convention_signed_applications_count: 0
      )
      InternshipOfferWeek.update_all(
        approved_applications_count: 0,
        blocked_applications_count: 0
      )
      InternshipApplication.all.map(&:update_all_counters)
    end
  end
end
