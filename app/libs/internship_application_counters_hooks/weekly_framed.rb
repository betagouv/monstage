# frozen_string_literal: true

module InternshipApplicationCountersHooks
  class WeeklyFramed < InternshipApplicationCountersHook
    delegate :internship_offer, to: :internship_application
    delegate :week, to: :internship_application

    # BEWARE: order matters
    def update_all_counters
      update_internship_offer_week_counters
      internship_offer.update(internship_offer_counters_attributes.merge(blocked_weeks_count: blocked_weeks_count))
    end

    # PERF: can be optimized with one query
    # w8 for perf issue [if it ever occures]
    # select sum(aasm_state == convention_signed) as convention_signed_count
    #        sum(aasm_state == approved) as approved_count )
    def update_internship_offer_week_counters
      internship_offer_week = InternshipOfferWeek.where(
        internship_offer: internship_offer.id,
        week_id: week.id 
      ).first
      
      internship_offer_week.update(
        blocked_applications_count: week.internship_applications
                                      .where(aasm_state: :approved)
                                      .count
      ) if internship_offer_week
    end

    private

    attr_reader :internship_application

    def initialize(internship_application:)
      @internship_application = internship_application
      @internship_application.reload
    end

    def blocked_weeks_count
      internship_offer.internship_offer_weeks
                      .where('internship_offer_weeks.blocked_applications_count > 0')
                      .count
    end
  end
end
