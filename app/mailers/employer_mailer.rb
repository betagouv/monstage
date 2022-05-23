# frozen_string_literal: true

class EmployerMailer < ApplicationMailer
  def internship_application_submitted_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: 'Une candidature vous attend, veuillez y répondre')
  end

  def internship_applications_reminder_email(employer:,
                                             remindable_application_ids: )
    @remindable_application_ids = InternshipApplication.where(id: remindable_application_ids)
    @employer = employer

    mail(to: @employer.email,
         subject: 'Candidatures en attente, veuillez y répondre')
  end

  def internship_application_canceled_by_student_email(internship_application:)
    @internship_application = internship_application

    mail(to: @internship_application.internship_offer.employer.email,
         subject: 'Information - Une candidature a été annulée')
  end

  def internship_application_approved_with_agreement_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    @url = dashboard_internship_offer_internship_applications_url(
      internship_offer_id: @internship_offer.id,
      id: internship_application.id,
      mtm_campaign: "Offreur - Convention Ready to Edit#internship-application-#{internship_application.id}"
    ).html_safe

    mail(to: @employer.email, subject: 'Veuillez compléter la convention de stage.')
  end

  def school_manager_finished_notice_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @employer              = @internship_offer.employer
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'Offreur - Convention Ready to Print'
    ).html_safe

    mail(to: @employer.email, subject: 'Imprimez et signez la convention de stage.')
  end

end
