require 'test_helper'

module Services
  class InternshipApplicationCountersHookTest < ActiveSupport::TestCase
    test 'update_internship_offer_week_counters' do
      internship_application       = create(:weekly_internship_application)
      other_internship_application = create(:weekly_internship_application)
      hook = InternshipApplicationCountersHooks::WeeklyFramed.new(
        internship_application: internship_application
      )
      assert hook.update_internship_offer_week_counters
      assert_equal 0, internship_application.internship_offer.total_applications_count
      internship_application.submit!
      assert hook.update_internship_offer_week_counters
      assert_equal 1, internship_application.internship_offer.total_applications_count
      other_internship_application.submit!
      assert hook.update_all_counters
      assert_equal 1, other_internship_application.internship_offer.total_applications_count
      refute internship_application.reload.approved?
      assert_equal 0, internship_application.internship_offer
                                            .internship_offer_weeks
                                            .first
                                            .blocked_applications_count
      internship_application.approve!
      assert_equal 1, internship_application.internship_offer
                                            .internship_offer_weeks
                                            .first
                                            .blocked_applications_count
    end
  end
end
