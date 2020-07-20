# frozen_string_literal: true

class EmployerMailer < ApplicationMailer
  def internship_application_submitted_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: 'Action requise – Répondre à la candidature')
  end

  def internship_applications_reminder_email(employer:,
                                             remindable_application_ids:,
                                             expirable_application_ids:)
    @remindable_application_ids = InternshipApplication.where(id: remindable_application_ids)
    @expirable_application_ids = InternshipApplication.where(id: expirable_application_ids)
    @employer = employer

    mail(to: @employer.email,
         subject: 'Action requise – Gérez vos candidatures')
  end

  def internship_application_canceled_by_student_email(internship_application:)
    puts 'in internship_application_canceled_by_student_email !'
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: 'Information – Annulation de candidature')
  end
end
