# frozen_string_literal: true

class EmployerMailer < ApplicationMailer
  def internship_application_submitted_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: 'Une candidature vous attend, veuillez y répondre')
  end

  def internship_applications_reminder_email(employer:,
                                             remindable_application_ids:,
                                             expirable_application_ids:)
    @remindable_application_ids = InternshipApplication.where(id: remindable_application_ids)
    @expirable_application_ids = InternshipApplication.where(id: expirable_application_ids)
    @employer = employer

    mail(to: @employer.email,
         subject: 'Candidatures en attente, veuillez y répondre')
  end

  def internship_application_canceled_by_student_email(internship_application:)
    puts 'in internship_application_canceled_by_student_email !'
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: 'Information – Annulation de candidature')
  end
end
