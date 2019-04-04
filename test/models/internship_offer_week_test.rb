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

  test "sum internship_offer.approved_weeks_count to internship_offer.approved_weeks_count" do
    internship_offer = create(:internship_offer, weeks: [Week.find_by(number: 1, year: 2019),
                                                         Week.find_by(number: 1, year: 2019)])

    internship_offer_week_1 = internship_offer.internship_offer_weeks.first
    internship_offer_week_2 = internship_offer.internship_offer_weeks.last

    assert_equal 0, internship_offer.approved_applications_count

    internship_offer_week_1.update!(approved_applications_count: 1)
    internship_offer.reload
    assert_equal 1, internship_offer.approved_applications_count

    internship_offer_week_1.update!(approved_applications_count: 2)
    internship_offer.reload
    assert_equal 2, internship_offer.approved_applications_count

    internship_offer_week_2.update!(approved_applications_count: 1)
    internship_offer.reload
    assert_equal 3, internship_offer.approved_applications_count

    internship_offer_week_2.update!(approved_applications_count: 2)
    internship_offer.reload
    assert_equal 4, internship_offer.approved_applications_count
  end

end
