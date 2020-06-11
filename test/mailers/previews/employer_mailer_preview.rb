class EmployerMailerPreview < ActionMailer::Preview
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

  def internship_application_submitted_email
    internship_application = InternshipApplication.submitted.first

    EmployerMailer.internship_application_submitted_email(internship_application: internship_application)
  end

  def internship_application_canceled_by_student_email
    internship_application = InternshipApplication.canceled_by_student.first
    message_builder = MessageForAasmState.new(
      internship_application: internship_application,
      aasm_target: :cancel_by_student!
    )
    message_builder.assigned_rich_text_attribute
    EmployerMailer.internship_application_canceled_by_student_email(internship_application: internship_application)
  end
end
