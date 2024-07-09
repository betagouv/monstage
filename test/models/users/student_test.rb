# frozen_string_literal: true

require 'test_helper'
module Users
  class StudentTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test 'student.after_sign_in_path redirects to internship_offers_path' do
      student = create(:student)
      assert_equal(student.after_sign_in_path,
                   student.presenter.default_internship_offers_path,
                   'failed to use default_internship_offers_path for user without targeted_offer_id')

      student.targeted_offer_id= 1
      assert_equal(student.after_sign_in_path,
                   Rails.application.routes.url_helpers.internship_offer_path(id: 1))

    end

    test 'validate wrong mobile phone format' do
      user = build(:student, phone: '+330111223344')
      refute user.valid?
      assert_equal ['Veuillez modifier le numéro de téléphone mobile'], user.errors.messages[:phone]
    end

    test 'validate wrong phone format' do
      user = build(:student, phone: '06111223344')
      refute user.valid?
      assert_equal ['Veuillez modifier le numéro de téléphone mobile'], user.errors.messages[:phone]
    end

    test 'validate good phone format' do
      user = build(:student, phone: '+330611223344')
      assert user.valid?
    end

    test 'no phone token creation after user creation' do
      user = create(:student, phone: '')
      assert_nil user.phone_token
      assert_nil user.phone_token_validity
    end

    test "#main_teacher" do
      school                     = create(:school)
      school_with_school_manager = create(:school, :with_school_manager)

      student_no_class_room = build(:student, class_room: nil)
      assert_nil student_no_class_room.class_room
      assert_nil student_no_class_room.main_teacher

      class_room = create(:class_room, school: school)
      student_with_class_room = build(:student, class_room: class_room)
      assert_nil student_with_class_room.main_teacher

      main_teacher   = create(:main_teacher, class_room: class_room, school: school_with_school_manager)
      main_teacher_2 = create(:main_teacher, class_room: class_room, school: school_with_school_manager)
      student        = create(:student, class_room: class_room, school: school_with_school_manager)
      assert_equal main_teacher.id, student.main_teacher.id
    end

    test "#school_and_offer_common_weeks when school has weeks" do
      travel_to Date.new(2020, 9, 1) do
        school_with_weeks = create(:school, :with_school_manager, weeks: Week.selectable_on_school_year.first(2))
        student = create(:student, school: school_with_weeks)
        assert_equal 2, student.school.weeks.count
        internship_offer = create(:weekly_internship_offer, weeks: [Week.selectable_on_school_year.first])
        misfitting_offer = create(:weekly_internship_offer, weeks: [Week.selectable_on_school_year.first(3).last])

        assert_equal [school_with_weeks.weeks.first], student.school_and_offer_common_weeks(internship_offer)
        assert_equal [], student.school_and_offer_common_weeks(misfitting_offer)
      end
    end

    test "#school_and_offer_common_weeks when school has no week" do
      travel_to Date.new(2020, 9, 1) do
        school_without_weeks = create(:school)
        student = create(:student, school: school_without_weeks)
        internship_offer = create(:weekly_internship_offer, weeks: [Week.selectable_on_school_year.first])

        assert  student.school_and_offer_common_weeks(internship_offer).empty?
      end
    end

    test "#available_offers" do
      travel_to Date.new(2020, 9, 1) do
        weeks_till_end = Week.selectable_from_now_until_end_of_school_year
        school         = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
        student        = create(:student, school: school)
        assert_equal 0 , student.available_offers.to_a.count
        create(:weekly_internship_offer, weeks:  weeks_till_end.last(2))
        # since no fit
        assert_equal 0 , student.available_offers.to_a.count
        # with one to fit
        internship_offer = create(:weekly_internship_offer, weeks:  weeks_till_end.first(2))
        assert_equal 1 , student.available_offers.to_a.count
        create(:weekly_internship_offer, coordinates: Coordinates.bordeaux, weeks: weeks_till_end.first(2))
        # still 1 since bordeaux won't fit
        assert_equal 1 , student.available_offers.to_a.count
        # and back to 0 if student has already applied
        create(:internship_application,
               student: student,
               internship_offer: internship_offer,
               week: weeks_till_end.second)
        assert_equal 0 , student.available_offers.to_a.count
      end
    end

    test "#has_offers_to_apply_to?" do
      travel_to Date.new(2020, 9, 1) do
        weeks_till_end = Week.selectable_from_now_until_end_of_school_year
        school         = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
        student        = create(:student, school: school)
        refute student.has_offers_to_apply_to?
        create(:weekly_internship_offer, weeks:  weeks_till_end.last(2))
        refute student.has_offers_to_apply_to?
        create(:weekly_internship_offer, weeks:  weeks_till_end.first(2))
        assert student.has_offers_to_apply_to?
      end
    end

    test "reminders are set after creation" do
      assert_enqueued_jobs 1, only: SendReminderToStudentsWithoutApplicationJob do
        student = create(:student)
      end
    end
  end
end
