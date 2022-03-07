# frozen_string_literal: true

class SchoolManagerMailer < ApplicationMailer
  def new_member(school_manager:, member:)
    @school_manager = school_manager
    @member_presenter = member.presenter
    @school_manager_presenter = school_manager.presenter

    mail(subject: "Nouveau #{@member_presenter.role_name}: #{@member_presenter.full_name}",
         to: school_manager.email)
  end

  def agreement_creation_notice_email(internship_agreement: )
    internship_application = internship_agreement.internship_application
    @internship_offer      = internship_application.internship_offer
    student                = internship_application.student
    @prez_stud             = student.presenter
    school_manager         = student.school.school_manager
    @url = edit_dashboard_internship_agreement_url(
      id: internship_agreement.id,
      mtm_campaign: 'ETB - Convention Almost Ready'
    ).html_safe

    mail(
      to: school_manager.email,
      subject: 'Une convention de stage sera bientôt disponible.'
    )
  end
end
