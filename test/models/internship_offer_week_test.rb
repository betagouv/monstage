require 'test_helper'

class InternshipOfferWeekTest < ActiveSupport::TestCase

  test "increment internship_offer.blocked_weeks_count when blocked_applications_count > 0" do
    internship_offer = create(:internship_offer, max_candidates: 1)
    internship_offer_week = internship_offer.internship_offer_weeks.first
    assert_equal 0, internship_offer.blocked_weeks_count

    internship_offer_week.update!(blocked_applications_count: 1)
    internship_offer.reload
    assert_equal 1, internship_offer.blocked_weeks_count

    internship_offer_week.update!(blocked_applications_count: 1)
    internship_offer.reload
    assert_equal 1, internship_offer.blocked_weeks_count
  end
end
