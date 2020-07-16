# frozen_string_literal: true

require 'test_helper'

class MainTeacherMailerTest < ActionMailer::TestCase
  test 'internship_application_approved_email' do
    internship_application = create(:weekly_internship_application)
    student  = internship_application.student
    school_manager = create(:school_manager, school: student.school)
    main_teacher = create(:main_teacher, class_room: student.class_room,
                                         school: student.school)
    email = MainTeacherMailer.internship_application_approved_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )

    assert_includes email.to, main_teacher.email
    assert_equal "Action requise - La candidature de #{Presenters::User.new(student).full_name} a été acceptée, convention de stage à gérer", email.subject
  end
end
