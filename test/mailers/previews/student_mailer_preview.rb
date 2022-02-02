class StudentMailerPreview < ActionMailer::Preview
  def internship_application_approved_email
    internship_application = InternshipApplications::WeeklyFramed.approved.first
    message = internship_application.internship_application_aasm_message_builder(aasm_target: :approve!)
                                    .mail_body
    internship_application.approved_message = message
    StudentMailer.internship_application_approved_email(
      internship_application: internship_application
    )
  end

  def internship_application_rejected_email
    internship_application = InternshipApplication.rejected.first
    message = internship_application.internship_application_aasm_message_builder(aasm_target: :reject!)
                                    .mail_body
    internship_application.rejected_message = message
    StudentMailer.internship_application_rejected_email(
      internship_application: internship_application
    )
  end

  def internship_application_canceled_by_employer_email
    internship_application = InternshipApplication.canceled_by_employer.first
    message = internship_application.internship_application_aasm_message_builder(aasm_target: :cancel_by_employer!)
                                    .mail_body
    internship_application.canceled_by_employer_message = message
    StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )
  end
end
