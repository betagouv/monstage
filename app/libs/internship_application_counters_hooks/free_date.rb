# frozen_string_literal: true

module InternshipApplicationCountersHooks
  # not yet implemented, should be consider with reporting/dashboarding for this kind of applications
  class FreeDate < InternshipApplicationCountersHook
    delegate :internship_offer, to: :internship_application

    # BEWARE: order matters
    def update_all_counters
      # update_internship_offer_week_counters
      internship_offer.update(internship_offer_counters_attributes)
    end
  end
end
