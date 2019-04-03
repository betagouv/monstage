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
    assert_equal internship_offer.school, nil
    assert internship_offer.build_school.is_a?(School)
  end

  test "test presence of fields" do
    internship_offer = InternshipOffer.create

    assert 0, InternshipOffer.count

    assert internship_offer.invalid?
    assert_not_empty internship_offer.errors[:title]
    assert_not_empty internship_offer.errors[:description]
    assert_not_empty internship_offer.errors[:sector]
    assert_not_empty internship_offer.errors[:max_weeks]
    assert_not_empty internship_offer.errors[:tutor_name]
    assert_not_empty internship_offer.errors[:tutor_phone]
    assert_not_empty internship_offer.errors[:tutor_email]
    assert_not_empty internship_offer.errors[:is_public]
    assert_not_empty internship_offer.errors[:employer_street]
    assert_not_empty internship_offer.errors[:employer_zipcode]
    assert_not_empty internship_offer.errors[:employer_city]
    assert_not_empty internship_offer.errors[:employer_name]
    assert_not_empty internship_offer.errors[:coordinates]
  end

  test "has spots left" do
    internship_offer = create(:internship_offer, max_candidates: 2, weeks: [Week.first, Week.last])

    assert internship_offer.has_spots_left?

    internship_offer.internship_offer_weeks.each do |internship_offer_week|
      internship_offer.max_candidates.times do
        create(:internship_application, internship_offer_week: internship_offer_week, aasm_state: 'approved')
      end
    end

    refute internship_offer.has_spots_left?
  end
end
