# frozen_string_literal: true

class MainTeacherMailer < ApplicationMailer
  # Reminder : when approving an application, every main_teacher receives an email
  def internship_application_approved_with_agreement_email(internship_application:, main_teacher:)
    @internship_application = internship_application
    @internship_offer= internship_application.internship_offer
    @student = @internship_application.student
    @student_presenter = @student.presenter
    @url = internship_offer_url(
      id: @internship_offer.id,
      mtm_campaign: 'application-details-no-agreement',
      mtm_kwd: 'email'
    ).html_safe
    @message = "Aucune convention n'est prévue sur ce site, bon stage à #{@student_presenter.civil_name} !"

    # TO DO Remove when main_teachers are cleaned
    main_teachers = @student.class_room.school_managements&.main_teachers
    to = main_teachers.blank? ? nil : main_teachers.map(&:email)
    subject = "La candidature d'un de vos élèves a été acceptée"
    cc = @student.school_manager_email

    send_email( to: to, subject: subject, cc: cc )
  end

  def internship_application_approved_with_no_agreement_email(internship_application:, main_teacher:)
    @main_teacher = main_teacher
    @internship_offer = internship_application.internship_offer
    @student = internship_application.student
    @student_presenter = @student.presenter
    @url = internship_offer_url(
      id: @internship_offer.id,
      mtm_campaign: 'application-details-no-agreement',
      mtm_kwd: 'email'
    ).html_safe

    # TO DO Remove when main_teachers are cleaned
    main_teachers = @student.class_room.school_managements&.main_teachers    
    to = main_teachers.blank? ? nil : main_teachers.map(&:email)
    subject = "Un de vos élèves a été accepté à un stage"
    cc = nil

    send_email(to: to, subject: subject, cc: cc)
  end
end
