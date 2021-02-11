# frozen_string_literal: true

require 'test_helper'

class MainTeacherMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test 'internship_application_approved_email within troisieme generale context' do
    school = create(:school, :with_school_manager, :with_weeks)
    student = create(:student_with_class_room_3e, school: school)
    internship_offer = create(:weekly_internship_offer, weeks: school.weeks)
    internship_application = create(:weekly_internship_application,
                                    :submitted,
                                    internship_offer: internship_offer,
                                    user_id: student.id)
    main_teacher = create(:main_teacher, class_room: school.class_rooms.first, school: school)
    school_manager = school.school_manager
    internship_application.approve!
    email = MainTeacherMailer.internship_application_approved_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )
    assert_includes email.to, school_manager.email
    assert_includes email.cc, main_teacher.email
    refute_email_spammyness(email)
  end
end
