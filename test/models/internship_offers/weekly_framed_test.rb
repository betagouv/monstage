# frozen_string_literal: true

require 'test_helper'

module InternshipsOffers
  class WeeklyFramedTest < ActiveSupport::TestCase
    test 'should be valid' do
      offer = build(:internship_offer)
      assert_equal offer.max_candidates, offer.remaining_seats_count
      assert offer.valid?
      offer.save
      assert offer.persisted?
    end

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

    test 'max_students_per_group' do
      internship_offer = build(:internship_offer,
                               max_candidates: 2,
                               max_students_per_group: 1,
                               weeks: [Week.first, Week.last])
      assert internship_offer.valid?

      internship_offer = build(:internship_offer,
                               max_candidates: 2,
                               max_students_per_group: 2,
                               weeks: [Week.first, Week.last])
      assert internship_offer.valid?

      internship_offer = build(:internship_offer,
                               max_candidates: 2,
                               max_students_per_group: 3,
                               weeks: [Week.first, Week.last])
      refute internship_offer.valid?
    end

    test 'group size is lower than max_candidates' do
      internship_offer = build(:internship_offer,
                                max_candidates: 2,
                                max_students_per_group: 3,
                                weeks: [Week.first, Week.last])
      refute internship_offer.valid?
      error_message = "Effectif max. d'un groupe d'élèves " \
                      "Le nombre maximal d'élèves par groupe ne peut pas" \
                      " dépasser le nombre maximal d'élèves " \
                      "attendus dans l'année"
      assert_equal error_message,
                   internship_offer.errors.full_messages.first
    end

    test 'fulfilled internship_offers' do
      internship_offer = create(:internship_offer,
                                max_candidates: 2,
                                max_students_per_group: 1,
                                weeks: Week.first(3))
      assert_equal 0, InternshipOffer.fulfilled.to_a.count
      first_io_week = internship_offer.internship_offer_weeks.first
      second_io_week = internship_offer.internship_offer_weeks.second
      third_io_week = internship_offer.internship_offer_weeks.last
      create(:internship_application,
             :approved,
             internship_offer: first_io_week.internship_offer,
             week: first_io_week.week)
      assert_equal 0, InternshipOffer.fulfilled.to_a.count
      create(:internship_application,
            :submitted,
            internship_offer: second_io_week.internship_offer,
            week: second_io_week.week)
      assert_equal 0, InternshipOffer.fulfilled.to_a.count
      create(:internship_application,
            :approved,
            internship_offer: second_io_week.internship_offer,
            week: third_io_week.week)
      assert_equal 1, InternshipOffer.fulfilled.to_a.count
    end

    test 'uncompleted internship_offers' do
      internship_offer = create(:internship_offer,
                                max_candidates: 2,
                                max_students_per_group: 1,
                                weeks: Week.first(3))
      assert_equal 1, InternshipOffer.uncompleted.count
      first_io_week = internship_offer.internship_offer_weeks.first
      second_io_week = internship_offer.internship_offer_weeks.second
      third_io_week = internship_offer.internship_offer_weeks.last
      create(:internship_application,
             :approved,
             internship_offer: first_io_week.internship_offer,
             week: first_io_week.week)
      assert_equal 1, InternshipOffer.uncompleted.count
      create(:internship_application,
            :submitted,
            internship_offer: second_io_week.internship_offer,
            week: second_io_week.week)
      assert_equal 1, InternshipOffer.uncompleted.count
      create(:internship_application,
            :approved,
            internship_offer: second_io_week.internship_offer,
            week: third_io_week.week)
      assert_equal 0, InternshipOffer.uncompleted.count
    end

    test 'ignore_max_candidates_reached internship_offers' do
      internship_offer = create(:internship_offer,
                                max_candidates: 2,
                                max_students_per_group: 2,
                                weeks: [Week.first, Week.last])

      assert_equal 1, InternshipOffer.uncompleted.to_a.count
      # assert_equal 1, InternshipOffer.ignore_max_candidates_reached.to_a.count
      first_io_week = internship_offer.internship_offer_weeks.first
      create(:internship_application,
             :approved,
             internship_offer: first_io_week.internship_offer,
             week: first_io_week.week)
      assert_equal 1, InternshipOffer.uncompleted.to_a.count
      create(:internship_application,
            :submitted,
            internship_offer: first_io_week.internship_offer,
            week: first_io_week.week)
      assert_equal 1, InternshipOffer.uncompleted.to_a.count
      create(:internship_application,
            :approved,
            internship_offer: first_io_week.internship_offer,
            week: first_io_week.week)
      internship_offer.reload


      assert_equal 0, InternshipOffer.uncompleted.to_a.count
    end

    test 'has spots left' do
      internship_offer = create(:internship_offer, max_candidates: 2, weeks: [Week.first, Week.last])

      assert internship_offer.has_spots_left?

      internship_offer.internship_offer_weeks.each do |internship_offer_week|
        (internship_offer.max_candidates - 1).times do
          create(:internship_application, internship_offer: internship_offer_week.internship_offer,
                                                 week: internship_offer_week.week,
                                                 aasm_state: 'approved')
        end
      end
      internship_offer.reload
      refute internship_offer.has_spots_left?
    end

    test 'sync_first_and_last_date' do
      first_io_week = Week.find_by(year: 2019, number: 50)
      last_week = Week.find_by(year: 2020, number: 2)
      internship_offer = create(:internship_offer, max_candidates: 2, weeks: [first_io_week, last_week])

      assert_equal internship_offer.first_date, first_io_week.week_date.beginning_of_week
      assert_equal internship_offer.last_date, last_week.week_date.end_of_week
    end

    test 'look for offers available in the future' do
      travel_to(Date.new(2020, 5, 15)) do
        internship_offer = create(:internship_offer, weeks: [Week.find_by(year: 2019, number: 50), Week.find_by(year: 2020, number: 10)])
        assert_empty InternshipOffer.in_the_future

        next_week = Week.find_by(year: 2020, number: 30)
        internship_offer.weeks << next_week
        internship_offer.save

        assert_equal 1, InternshipOffer.in_the_future.count
      end
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

    test 'RGPD' do
      internship_offer = create(:internship_offer, tutor_name: 'Eric', tutor_phone: '0123456789',
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
      internship_offer = create(:internship_offer, weeks: [Week.first, Week.last])
      assert_equal 2, internship_offer.internship_offer_weeks_count

      internship_offer.weeks << Week.find_by(number: 10, year: 2020)
      assert_equal 3, internship_offer.internship_offer_weeks_count
    end

    test 'duplicate' do
      internship_offer = create(:internship_offer, description_rich_text: 'abc',
                                                          employer_description_rich_text: 'def')
      duplicated_internship_offer = internship_offer.duplicate
      assert_equal internship_offer.description_rich_text.to_plain_text.strip,
                   duplicated_internship_offer.description_rich_text.to_plain_text.strip
      assert_equal internship_offer.employer_description_rich_text.to_plain_text.strip,
                   duplicated_internship_offer.employer_description_rich_text.to_plain_text.strip
    end

    test 'default max_candidates' do
      assert_equal 1, InternshipOffer.new.max_candidates
      assert_equal 1, InternshipOffer.new(max_candidates: '').max_candidates
    end
  end
end
