# frozen_string_literal: true

# Services::CounterManager.reset_internship_offer_counters
# Services::CounterManager.reset_internship_offer_weeks_counter
module Services
  class CounterManager
    def self.reset_internship_offer_counters
      InternshipOffer.kept.update_all(
        total_applications_count: 0,
        total_male_applications_count: 0,
        total_female_applications_count: 0,
        submitted_applications_count: 0,
        approved_applications_count: 0,
        total_male_approved_applications_count: 0,
        total_female_approved_applications_count: 0,
        total_custom_track_approved_applications_count: 0,
        rejected_applications_count: 0,
        convention_signed_applications_count: 0,
        total_male_convention_signed_applications_count: 0,
        total_female_convention_signed_applications_count: 0,
        total_custom_track_convention_signed_applications_count: 0
      )
      InternshipOfferWeek.update_all(
        blocked_applications_count: 0
      )
      InternshipApplication.all.map(&:update_all_counters)
    end

    def self.reset_internship_offer_weeks_counter
      InternshipOffers::WeeklyFramed.kept.find_each do |internship_offer|
        InternshipOffers::WeeklyFramed.reset_counters(internship_offer.id, :internship_offer_weeks)
      end
    end
  end
end
