# frozen_string_literal: true

module InternshipApplicationCountersHooks
  class FreeDate < InternshipApplicationCountersHook
    delegate :internship_offer, to: :internship_application

    # BEWARE: order matters
    def update_all_counters
      # update_internship_offer_week_counters
      # update_internship_offer_counters
    end
  end
end
