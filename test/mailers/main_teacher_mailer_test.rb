# frozen_string_literal: true

require 'test_helper'

class MainTeacherMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test 'internship_application_approved_email' do
    # internship_application = create(:internship_application)
    # student = internship_application.student
    # create(:school_manager, school: student.school)
    # main_teacher = create(:main_teacher, class_room: student.class_room,
    #                                      school: student.school)
    school                 = create(:school, :with_school_manager)
    class_room             = create(:class_room, school: school)
    student                = create(:student, school: school, class_room: class_room)
    main_teacher           = create(:main_teacher, school: school, class_room: class_room)
    internship_application = create(:internship_application_with_agreement, user_id: student.id)
    # internship_agreement   = internship_application.internship_agreement
    email = MainTeacherMailer.internship_application_approved_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )

    assert_includes email.to, main_teacher.email
    refute_email_spammyness(email)
  end
end
