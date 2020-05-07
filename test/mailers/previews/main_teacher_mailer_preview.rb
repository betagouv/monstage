# frozen_string_literal: true

class MainTeacherMailerPreview < ActionMailer::Preview
  def internship_application_approved_email
    internship_application = InternshipApplication.approved
                                                  .first
    main_teacher = internship_application.student
                                         .school
                                         .main_teachers
                                         .first
    MainTeacherMailer.internship_application_approved_email(
      internship_application: internship_application,
      main_teacher: main_teacher
    )
  end
end
