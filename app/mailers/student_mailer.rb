# frozen_string_literal: true

class StudentMailer < ApplicationMailer

  def internship_application_approved_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: "Une de vos candidatures a été acceptée")
  end

  def internship_application_rejected_email(internship_application:)
    @internship_application = internship_application
    @host = EmailUtils.env_host
    @url = internship_offers_url

    mail(to: @internship_application.student.email,
         subject: "Une de vos candidatures a été refusée")
  end

  def internship_application_canceled_by_employer_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: "Une de vos candidatures a été annulée")
  end

  def internship_application_examined_email(internship_application:)
    @internship_application = internship_application
    @student = internship_application.student
    @internship_offer = internship_application.internship_offer
    @prez_offer = @internship_offer.presenter
    @prez_student = @student.presenter

    send_email(to: @student.email,
               subject: "Votre candidature est en cours d'examen")
  end

  def internship_application_requested_confirmation_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: "Une de vos candidatures a été acceptée")
  end

  def account_created_by_teacher(student:, teacher:, token:)
    @student = student
    @teacher = teacher
    @token = token

    mail(to: @student.email,
         subject: "Votre inscription sur MonStageDeTroisieme.fr")
  end

  def internship_application_validated_by_employer_email(internship_application:)
    @internship_application = internship_application
    @student = internship_application.student
    @internship_offer = internship_application.internship_offer
    @prez_offer = @internship_offer.presenter
    @prez_student = @student.presenter
    sgid = @student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
    @url = dashboard_students_internship_application_url(
      sgid: sgid,
      student_id: @student.id,
      id: @internship_application.id
    )

    send_email(to: @student.email,
               subject: "Votre candidature a été validée par l'employeur")
  end

  def internship_application_validated_by_employer_reminder_email(applications_to_notify:)
    @internship_applications = applications_to_notify
    @internship_application = @internship_applications.last
    @plural = @internship_applications.size >= 2
    @student = applications_to_notify.first.student
    @internship_offers = applications_to_notify.map(&:internship_offer)
    @titles = @internship_offers.map(&:title)
    @prez_student = @student.presenter
    sgid = @student.to_sgid(expires_in: InternshipApplication::MAGIC_LINK_EXPIRATION_DELAY).to_s
    @url = dashboard_students_internship_application_url(
      sgid: sgid,
      student_id: @student.id,
      id: @internship_application.id
    )

    send_email(to: @student.email,
               subject: "[Relance] - Candidature validée par l'employeur")
  end

  def internship_application_expired_email(internship_application:)
    @internship_application = internship_application
    @student = internship_application.student
    @internship_offer = internship_application.internship_offer
    @prez_offer = @internship_offer.presenter
    @prez_student = @student.presenter

    send_email(to: @student.email,
               subject: "Votre candidature a expiré")
  end
end
