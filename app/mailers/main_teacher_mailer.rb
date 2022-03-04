# frozen_string_literal: true

class MainTeacherMailer < ApplicationMailer
  # Reminder : when approving an application, every main_teacher receives an email
  def internship_application_approved_email(internship_application:, main_teacher:)
    @internship_application = internship_application
    @student = @internship_application.student
    @student_presenter = Presenters::User.new(@student)
    main_teacher_email = main_teacher&.email

    if @student.troisieme_generale?
      to = @student.school_manager_email
      return if to.nil?

      subject = "Convention de stage à renseigner: #{@student_presenter.civil_name}"
      cc = main_teacher_email
      @url = edit_dashboard_internship_agreement_url(@internship_application.internship_agreement)
      @message = "La convention dématérialisée peut être renseignée dès maintenant par le chef d'établissement ou le professeur principal"
    else
      to = main_teacher_email
      return if to.nil?

      subject = "Stage accepté pour #{@student_presenter.civil_name}"
      cc = @student.school_manager_email
      @message = "Aucune convention n'est prévue sur ce site, bon stage à #{@student_presenter.civil_name} !"
    end

    params = { to: to, subject: subject }
    params.merge!(cc: cc) unless cc.nil?
    mail(params)
  end
end
