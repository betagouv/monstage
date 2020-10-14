# frozen_string_literal: true

require 'test_helper'

module InternshipsOffers
  class WeeklyFramedTest < ActiveSupport::TestCase
    test 'association internship_offer_weeks' do
      internship_offer = InternshipOffers::WeeklyFramed.new
      assert_equal internship_offer.internship_offer_weeks, []
    end

    test 'association weeks' do
      internship_offer = InternshipOffers::WeeklyFramed.new
      assert_equal internship_offer.weeks, []
    end

    test 'school (restricted_school)' do
      internship_offer = InternshipOffers::WeeklyFramed.new
      assert_nil internship_offer.school
      assert internship_offer.build_school.is_a?(School)
    end

    test 'test presence of fields' do
      internship_offer = InternshipOffers::WeeklyFramed.new

      assert internship_offer.invalid?
      assert_not_empty internship_offer.errors[:title]
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
      internship_offer = create(:weekly_internship_offer, max_candidates: 2, weeks: [Week.first, Week.last])

      assert internship_offer.has_spots_left?

      internship_offer.internship_offer_weeks.each do |internship_offer_week|
        internship_offer.max_candidates.times do
          create(:weekly_internship_application, internship_offer: internship_offer_week.internship_offer,
                                                 internship_offer_week: internship_offer_week,
                                                 aasm_state: 'convention_signed')
        end
      end
      internship_offer.reload
      refute internship_offer.has_spots_left?
    end

    test 'sync_first_and_last_date' do
      first_week = Week.find_by(year: 2019, number: 50)
      last_week = Week.find_by(year: 2020, number: 2)
      internship_offer = create(:weekly_internship_offer, max_candidates: 2, weeks: [first_week, last_week])

      assert_equal internship_offer.first_date, first_week.week_date.beginning_of_week
      assert_equal internship_offer.last_date, last_week.week_date.end_of_week
    end

    test 'look for offers available in the future' do
      travel_to(Date.new(2020, 5, 15)) do
        internship_offer = create(:weekly_internship_offer, weeks: [Week.find_by(year: 2019, number: 50), Week.find_by(year: 2020, number: 10)])
        assert_empty InternshipOffers::WeeklyFramed.in_the_future

        next_week = Week.find_by(year: 2020, number: 30)
        internship_offer.weeks << next_week
        internship_offer.save

        assert_equal 1, InternshipOffers::WeeklyFramed.in_the_future.count
      end
    end

    test '.reverse_academy_by_zipcode works on create and save' do
      internship_offer = build(:weekly_internship_offer, zipcode: '75015')
      assert_changes -> { internship_offer.academy },
                     from: '',
                     to: 'Académie de Paris' do
        internship_offer.save
      end
    end

    test '.reverse_department_by_zipcode works on create and save' do
      internship_offer = build(:weekly_internship_offer, zipcode: '62000', department: 'Arras')
      assert_changes -> { internship_offer.department },
                     from: 'Arras',
                     to: 'Pas-de-Calais' do
        internship_offer.save
      end
    end

    test 'RGPD' do
      internship_offer = create(:weekly_internship_offer, tutor_name: 'Eric', tutor_phone: '0123456789',
                                                          tutor_email: 'eric@octo.com', title: 'Test', description: 'Test', employer_website: 'Test',
                                                          street: 'rue', employer_name: 'Octo', employer_description: 'Test')

      internship_offer.anonymize

      assert_not_equal 'Eric', internship_offer.tutor_name
      assert_not_equal '0123456789', internship_offer.tutor_phone
      assert_not_equal 'eric@octo.com', internship_offer.tutor_email
      assert_not_equal 'Test', internship_offer.title
      assert_not_equal 'Test', internship_offer.description
      assert_not_equal 'Test', internship_offer.employer_website
      assert_not_equal 'rue', internship_offer.street
      assert_not_equal 'Test', internship_offer.employer_name
      assert_not_equal 'Test', internship_offer.employer_description
    end

    test 'check if internship_offer_weeks_count counter is properly set' do
      internship_offer = create(:weekly_internship_offer, weeks: [Week.first, Week.last])
      assert_equal 2, internship_offer.internship_offer_weeks_count

      internship_offer.weeks << Week.find_by(number: 10, year: 2020)
      assert_equal 3, internship_offer.internship_offer_weeks_count
    end

    test 'duplicate' do
      internship_offer = create(:weekly_internship_offer, description_rich_text: 'abc',
                                                          employer_description_rich_text: 'def')
      duplicated_internship_offer = internship_offer.duplicate
      assert_equal internship_offer.description_rich_text.to_plain_text.strip,
                   duplicated_internship_offer.description_rich_text.to_plain_text.strip
      assert_equal internship_offer.employer_description_rich_text.to_plain_text.strip,
                   duplicated_internship_offer.employer_description_rich_text.to_plain_text.strip
    end

    test 'default max_candidates' do
      assert_equal 1, InternshipOffers::WeeklyFramed.new.max_candidates
      assert_equal 1, InternshipOffers::WeeklyFramed.new(max_candidates: '').max_candidates
    end
  end
end
