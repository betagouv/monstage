# frozen_string_literal: true

class SchoolManagerMailer < ApplicationMailer
  def new_member(school_manager:, member:)
    @school_manager = school_manager
    @member_presenter = member.presenter
    @school_manager_presenter = school_manager.presenter

    mail(subject: "Nouveau #{@member_presenter.role_name}: #{@member_presenter.full_name}",
         to: school_manager.email)
  end

  def internship_application_approved_with_agreement_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    school_manager         = student.school.school_manager
    @url = edit_dashboard_internship_agreement_url(
      id: internship_agreement.id,
      mtm_campaign: 'ETB - Convention Almost Ready'
    ).html_safe

    to = school_manager.email
    subject = 'Une convention de stage sera bientôt disponible.'

    send_email(to: to, subject: subject)
  end

  def internship_application_approved_with_no_agreement_email(internship_application: , main_teacher: nil)
    @internship_application = internship_application
    @internship_offer = internship_application.internship_offer
    @student = @internship_application.student
    @student_presenter = Presenters::User.new(@student)

    to = @student.school_manager_email
    @url = internship_offer_url(
      id: @internship_offer.id,
      mtm_campaign: 'application-details-with-no-agreement',
      mtm_kwd: 'email'
    ).html_safe

    subject = "Un de vos élèves a été accepté à un stage"

    send_email(to: to, subject: subject)
  end

  def notify_others_signatures_started_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @school_manager        = internship_agreement.school_manager
    @employer              = internship_agreement.employer
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'SchoolManager - Convention Ready to Sign'
    ).html_safe

    send_email(
      to: @school_manager.email,
      subject: 'Une convention de stage est prête à être signée !'
    )
  end

  def notify_others_signatures_finished_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    @school_manager        = internship_agreement.school_manager
    @employer              = internship_agreement.employer
    @url = dashboard_internship_agreements_url(
      id: internship_agreement.id,
      mtm_campaign: 'SchoolManager - Convention Signed and Ready'
    ).html_safe

    send_email(
      to: @school_manager.email,
      subject: 'Dernière ligne droite pour la convention de stage'
    )
  end
end
