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
  test "school (restricted_school)" do
    internship_offer = InternshipOffer.new
    assert_nil internship_offer.school
    assert internship_offer.build_school.is_a?(School)
  end

  test "test presence of fields" do
    internship_offer = InternshipOffer.new

    assert internship_offer.invalid?
    assert_not_empty internship_offer.errors[:title]
    assert_not_empty internship_offer.errors[:description]
    assert_not_empty internship_offer.errors[:sector]
    assert_not_empty internship_offer.errors[:tutor_name]
    assert_not_empty internship_offer.errors[:tutor_phone]
    assert_not_empty internship_offer.errors[:tutor_email]
    assert_not_empty internship_offer.errors[:is_public]
    assert_not_empty internship_offer.errors[:street]
    assert_not_empty internship_offer.errors[:zipcode]
    assert_not_empty internship_offer.errors[:city]
    assert_not_empty internship_offer.errors[:employer_name]
    assert_not_empty internship_offer.errors[:coordinates]
  end

  test "has spots left" do
    internship_offer = create(:internship_offer, max_candidates: 2, weeks: [Week.first, Week.last])

    assert internship_offer.has_spots_left?

    internship_offer.internship_offer_weeks.each do |internship_offer_week|
      internship_offer.max_candidates.times do
        create(:internship_application, internship_offer_week: internship_offer_week, aasm_state: 'convention_signed')
      end
    end
    internship_offer.reload
    refute internship_offer.has_spots_left?
  end

  test "look for offers available in the future" do
    travel_to(Date.new(2020, 5, 15)) do
      internship_offer = create(:internship_offer, weeks: [ Week.find_by(year: 2019, number: 50), Week.find_by(year: 2020, number: 10)])
      assert_empty InternshipOffer.available_in_the_future

      next_week = Week.find_by(year: 2020, number: 30)
      internship_offer.weeks << next_week

      assert_equal 1, InternshipOffer.available_in_the_future.count
    end
  end

  test "scopes that select offers depending on years" do
    travel_to(Date.new(2019, 5, 15)) do
      create(:internship_offer)

      assert_equal 1, InternshipOffer.during_current_year.count
      assert_equal 1, InternshipOffer.during_year(year: 2018).count
      assert_equal 0, InternshipOffer.during_year(year: 2019).count
    end
  end
end
