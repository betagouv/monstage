require 'test_helper'

class InternshipApplicationTest < ActiveSupport::TestCase

  test "cannot create application if offer is full" do
     internship_offer = create(:internship_offer, max_candidates: 1)

     internship_offer_week = internship_offer.internship_offer_weeks.first
     internship_application = create(:internship_application, internship_offer_week: internship_offer_week)

     assert internship_application.valid?

     internship_application.approve!

     internship_application = build(:internship_application, internship_offer_week: internship_offer_week)

     refute internship_application.valid?
  end
end
