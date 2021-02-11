# frozen_string_literal: true

class MainTeacherMailer < ApplicationMailer
  def internship_application_approved_email(internship_application:, main_teacher:)
    @internship_application = internship_application
    @student = @internship_application.student
    @student_presenter = Presenters::User.new(@student)

    if @student.troisieme_generale?
      to = @student.school_manager.email
      subject = "Convention de stage à renseigner: #{@student_presenter.civil_name}"
      cc = @student.main_teacher.email
      @url = edit_dashboard_internship_agreement_url(@internship_application.internship_agreement)
      @message = "La convention dématérialisée peut être renseignée dès maintenant par le chef d'établissement ou le professeur principal"
    else
      to = @student.main_teacher.email
      subject = "Stage accepté pour #{@student_presenter.civil_name}"
      cc = @student.school_manager.email
      @message = "Aucune convention n'est prévue sur ce site, bon stage à #{@student_presenter.civil_name} !"
    end

    mail(to: to, subject: subject, cc: cc)
  end
end
