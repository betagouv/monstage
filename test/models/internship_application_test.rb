require 'test_helper'

class InternshipApplicationTest < ActiveSupport::TestCase

  test "can create application if offer is not full" do
    internship_offer = create(:internship_offer, max_candidates: 1)
    internship_offer_week = internship_offer.internship_offer_weeks.first
    internship_application = build(:internship_application, internship_offer_week: internship_offer_week)
    assert internship_application.valid?
  end

  test "creating an application increment internship_offer.total_applications_count" do
    internship_offer = create(:internship_offer, max_candidates: 1)
    internship_offer_week = internship_offer.internship_offer_weeks.first
    internship_application = create(:internship_application, internship_offer_week: internship_offer_week)
    internship_offer.reload
    assert_equal 1, internship_offer.total_applications_count
  end

  test "cannot create application if offer is not full" do
    max_candidates = 1
    internship_offer_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                          week: Week.first)
    internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                 internship_offer_weeks: [internship_offer_week])
    internship_application = build(:internship_application, internship_offer_week: internship_offer_week)
    refute internship_application.valid?
  end

  test "internship_application.approve! increment internship_offer_weeks.blocked_applications_count" do
    internship_offer = create(:internship_offer, max_candidates: 1)
    internship_offer_week = internship_offer.internship_offer_weeks.first
    internship_application = create(:internship_application, internship_offer_week: internship_offer_week)
    internship_offer_week.reload
    assert_equal 0, internship_offer_week.blocked_applications_count
    internship_application.approve!
    internship_offer_week.reload
    assert_equal 1, internship_offer_week.blocked_applications_count
  end

  test "internship_application.reject! deos not increment internship_offer_weeks.blocked_applications_count" do
    internship_offer = create(:internship_offer, max_candidates: 1)
    internship_offer_week = internship_offer.internship_offer_weeks.first
    internship_application = create(:internship_application, internship_offer_week: internship_offer_week)
    internship_offer_week.reload

    assert_equal 0, internship_offer_week.blocked_applications_count
    internship_application.reject!
    internship_offer_week.reload
    assert_equal 0, internship_offer_week.blocked_applications_count
  end
end
