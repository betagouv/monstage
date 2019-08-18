# frozen_string_literal: true

class EmployerMailer < ApplicationMailer
  def internship_application_submitted_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: "Nouvelle candidature au stage #{@internship_application.internship_offer.title}")
  end
end
