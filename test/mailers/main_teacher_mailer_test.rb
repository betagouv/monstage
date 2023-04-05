# frozen_string_literal: true

require 'test_helper'

class MainTeacherMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test '#internship_application_approved_with_no_agreement_email' do
    school = create(:school, :with_school_manager, :with_weeks)
    student = create(:student_with_class_room_3e, school: school)
    internship_offer = create(:internship_offer, weeks: school.weeks)
    internship_application = create(:internship_application,
                                    :approved,
                                    internship_offer: internship_offer,
                                    user_id: student.id)
    main_teacher = create(:main_teacher, class_room: school.class_rooms.first, school: school)
    school_manager = school.school_manager
    # internship_application.approve!
    email = MainTeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )
    assert_includes 'Un de vos élèves a été accepté à un stage', email.subject
    assert_includes email.to, main_teacher.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end

  test '#internship_application_approved_with_no_agreement_email sent to all main_teachers' do
    school = create(:school, :with_school_manager, :with_weeks)
    student = create(:student_with_class_room_3e, school: school)
    internship_offer = create(:internship_offer, weeks: school.weeks)
    internship_application = create(:internship_application,
                                    :approved,
                                    internship_offer: internship_offer,
                                    user_id: student.id)
    main_teacher = create(:main_teacher, class_room: school.class_rooms.first, school: school)
    main_teacher_2 = create(:main_teacher, class_room: school.class_rooms.first, school: school)
    school_manager = school.school_manager
    # internship_application.approve!
    email = MainTeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )
    assert_includes 'Un de vos élèves a été accepté à un stage', email.subject
    assert_includes email.to, main_teacher.email
    assert_includes email.to, main_teacher_2.email
    assert_nil email.cc
    refute_email_spammyness(email)
  end

end
