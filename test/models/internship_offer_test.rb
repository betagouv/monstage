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

  test "test presence of fields" do
    internship_offer = InternshipOffer.create

    assert 0, InternshipOffer.count

    assert internship_offer.invalid?
    assert_not_empty internship_offer.errors[:title]
    assert_not_empty internship_offer.errors[:description]
    assert_not_empty internship_offer.errors[:sector]
    assert_not_empty internship_offer.errors[:max_candidates]
    assert_not_empty internship_offer.errors[:max_weeks]
    assert_not_empty internship_offer.errors[:tutor_name]
    assert_not_empty internship_offer.errors[:tutor_phone]
    assert_not_empty internship_offer.errors[:supervisor_email]
    assert_not_empty internship_offer.errors[:is_public]
    assert_not_empty internship_offer.errors[:employer_street]
    assert_not_empty internship_offer.errors[:employer_zipcode]
    assert_not_empty internship_offer.errors[:employer_city]
  end

  test "number of candidates required when can_be_applied_for is false" do
    internship_offer = InternshipOffer.new(max_candidates: 0,
                                           can_be_applied_for: true)
    internship_offer.valid?
    assert_empty internship_offer.errors[:max_candidates]

    internship_offer = InternshipOffer.new(max_candidates: 0,
                                           can_be_applied_for: false)
    internship_offer.valid?
    assert_not_empty internship_offer.errors[:max_candidates]
  end
end
