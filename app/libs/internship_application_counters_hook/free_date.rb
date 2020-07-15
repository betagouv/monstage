# frozen_string_literal: true

module InternshipApplicationCountersHook
  class FreeDate
    delegate :internship_offer, to: :internship_application

    # BEWARE: order matters
    def update_all_counters
      # update_internship_offer_week_counters
      # update_internship_offer_counters
    end

    private
    attr_reader :internship_application

    def initialize(internship_application:)
      @internship_application = internship_application
      @internship_application.reload
    end
  end
end
