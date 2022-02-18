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
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: 'Information – Annulation de candidature')
  end

  def agreement_creation_notice_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = Presenters::User.new(student)
    @employer              = @internship_offer.employer

    mail(to: @employer.email, subject: "x"*35)
  end

  def school_manager_finished_notice_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = Presenters::User.new(student)
    @employer              = @internship_offer.employer

    mail(to: @employer.email, subject: "x"*35)
  end

end
