# frozen_string_literal: true

class MainTeacherMailer < ApplicationMailer
  def internship_application_approved_email(internship_application:, main_teacher:)
    @internship_application = internship_application
    student = @internship_application.student
    @student_presenter = Presenters::User.new(student)

    mail(to: main_teacher.email,
         subject: "Action requise - La candidature de  #{@student_presenter.full_name}  a été acceptée, convention de stage à gérer")
  end
end
