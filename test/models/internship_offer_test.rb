require 'test_helper'

class InternshipOfferTest < ActiveSupport::TestCase
  test "association internship_offer_weeks" do
    internship_offer = InternshipOffer.new
    assert_equal internship_offer.internship_offer_weeks, []
  end

  test "association weeks" do
    internship_offer = InternshipOffer.new
    assert_equal internship_offer.weeks, []
  end
end
