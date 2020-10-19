class StudentMailerPreview < ActionMailer::Preview
  def internship_application_approved_email
    internship_application = InternshipApplication.approved.first
    StudentMailer.internship_application_approved_email(internship_application: internship_application)
  end

  def internship_application_rejected_email
    internship_application = InternshipApplication.rejected.first
    StudentMailer.internship_application_rejected_email(internship_application: internship_application)
  end

  def internship_application_canceled_by_employer_email
    internship_application = InternshipApplication.canceled_by_employer.first
    StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )
  end

  def account_activated_by_main_teacher_email
    StudentMailer.account_activated_by_main_teacher_email(user: Users::Student.first)
  end
end
