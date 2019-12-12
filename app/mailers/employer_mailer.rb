# frozen_string_literal: true

class EmployerMailer < ApplicationMailer
  def internship_application_submitted_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: "Nouvelle candidature au stage #{@internship_application.internship_offer.title}")
  end

  def internship_applications_reminder_email(pending_applications:,
                                             rejected_applications:)
    @pending_applications = pending_applications
    @rejected_applications = rejected_applications
    @employer = @pending_applications.first.internship_offer.employer

    mail(to: @employer.email,
         subject: "Action requise : des candidatures vous attendent")
  end
end

