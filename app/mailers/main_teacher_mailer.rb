# frozen_string_literal: true

class MainTeacherMailer < ApplicationMailer
  # Reminder : when approving an application, every main_teacher receives an email
  def internship_application_approved_email(internship_application:, main_teacher:)
    @internship_application = internship_application
    @student = @internship_application.student
    @student_presenter = @student.presenter

    to = main_teacher&.email
    return if to.nil?

    subject = "La candidature d'un de vos élèves a été acceptée"
    cc = @student.school_manager_email
    @message = "Aucune convention n'est prévue sur ce site, bon stage à #{@student_presenter.civil_name} !"

    send_email({ to: to, subject: subject, cc: cc })
  end

  def internship_application_with_no_agreement_email(internship_application:, main_teacher:)
    "tested ok"
  end
end
