# frozen_string_literal: true

require 'test_helper'

class MainTeacherMailerTest < ActionMailer::TestCase
  test 'internship_application_approved_email' do
    class_room = build(:class_room)
    main_teacher = build(:main_teacher, class_room: class_room)
    student = build(:student, class_room: class_room)
    internship_application = build(:internship_application, student: student)

    email = MainTeacherMailer.internship_application_approved_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )

    assert_includes email.to, main_teacher.email
    assert_equal "Action requise - La candidature de  #{Presenters::User.new(student).full_name}  a été acceptée, convention de stage à gérer", email.subject
  end
end
