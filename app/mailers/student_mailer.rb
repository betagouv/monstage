# frozen_string_literal: true

class StudentMailer < ApplicationMailer
  def internship_application_approved_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: "Votre candidature au stage #{@internship_application.internship_offer.title} a été acceptée")
  end

  def internship_application_rejected_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: "Votre candidature au stage #{@internship_application.internship_offer.title} a été rejetée")
  end

  def internship_application_canceled_by_employer_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.student.email,
         subject: "Votre candidature au stage #{@internship_application.internship_offer.title} a été annulée")
  end
end
