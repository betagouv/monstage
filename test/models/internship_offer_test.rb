# frozen_string_literal: true

require 'test_helper'

class InternshipOfferTest < ActiveSupport::TestCase
  test 'association internship_offer_weeks' do
    internship_offer = InternshipOffer.new
    assert_equal internship_offer.internship_offer_weeks, []
  end

  test 'association weeks' do
    internship_offer = InternshipOffer.new
    assert_equal internship_offer.weeks, []
  end
  test 'school (restricted_school)' do
    internship_offer = InternshipOffer.new
    assert_nil internship_offer.school
    assert internship_offer.build_school.is_a?(School)
  end

  test 'test presence of fields' do
    internship_offer = InternshipOffer.new

    assert internship_offer.invalid?
    assert_not_empty internship_offer.errors[:title]
    assert_not_empty internship_offer.errors[:description]
    assert_not_empty internship_offer.errors[:sector]
    assert_not_empty internship_offer.errors[:tutor_name]
    assert_not_empty internship_offer.errors[:tutor_phone]
    assert_not_empty internship_offer.errors[:tutor_email]
    assert_not_empty internship_offer.errors[:is_public]
    assert_not_empty internship_offer.errors[:zipcode]
    assert_not_empty internship_offer.errors[:city]
    assert_not_empty internship_offer.errors[:employer_name]
    assert_not_empty internship_offer.errors[:coordinates]
  end

  test 'has spots left' do
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

  test 'look for offers available in the future' do
    travel_to(Date.new(2020, 5, 15)) do
      internship_offer = create(:internship_offer, weeks: [Week.find_by(year: 2019, number: 50), Week.find_by(year: 2020, number: 10)])
      assert_empty InternshipOffer.available_in_the_future

      next_week = Week.find_by(year: 2020, number: 30)
      internship_offer.weeks << next_week

      assert_equal 1, InternshipOffer.available_in_the_future.count
    end
  end

  test '.has_operator?' do
    operator = create(:operator)
    internship_offer = create(:internship_offer, operators: [operator])
    assert internship_offer.has_operator?

    internship_offer = create(:internship_offer)
    refute internship_offer.has_operator?
  end


  test '.reverse_academy_by_zipcode works on create and save' do
    internship_offer = build(:internship_offer, zipcode: '75015')
    assert_changes -> { internship_offer.academy },
                  from: '',
                  to: 'Académie de Paris' do
      internship_offer.save
    end
  end

  test '.reverse_department_by_zipcode works on create and save' do
    internship_offer = build(:internship_offer, zipcode: '62000', department: 'Arras')
    assert_changes -> { internship_offer.department },
                  from: 'Arras',
                  to: 'Pas-de-Calais' do
      internship_offer.save
    end
  end
end
