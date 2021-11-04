class EmployerMailerPreview < ActionMailer::Preview
  def internship_application_submitted_email
    internship_application = InternshipApplication.submitted.first

    EmployerMailer.internship_application_submitted_email(
      internship_application: internship_application
    )
  end

  def internship_applications_reminder_email
    employer = InternshipApplication.first
                                    .internship_offer
                                    .employer
    EmployerMailer.internship_applications_reminder_email(
      employer: employer,
      remindable_application_ids: employer.internship_applications,
      expirable_application_ids: employer.internship_applications
    )
  end

  def internship_application_canceled_by_student_email
    internship_application = InternshipApplication&.approved&.first
    internship_application.canceled_by_student_message.body = "J'ai trouvé un autre stage ailleurs"
    EmployerMailer.internship_application_canceled_by_student_email(
      internship_application: internship_application
    )
  end
end
