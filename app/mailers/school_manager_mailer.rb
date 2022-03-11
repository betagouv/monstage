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

    to = school_manager.email
    subject = 'Une convention de stage sera bientôt disponible.'

    send_email({ to: to, subject: subject})
  end

 
  def internship_application_approved_email(internship_application: , main_teacher: nil)
    @internship_application = internship_application
    @student = @internship_application.student
    @student_presenter = Presenters::User.new(@student)

    to = @student.school_manager_email
    return if to.nil?

    subject = "Convention de stage à renseigner: #{@student_presenter.civil_name}"
    cc = main_teacher&.email
    @url = edit_dashboard_internship_agreement_url(@internship_application.internship_agreement)
    @message = "La convention dématérialisée peut être renseignée dès maintenant par le chef d'établissement ou le professeur principal"

    send_email({ to: to, subject: subject, cc: cc })
  end
end
