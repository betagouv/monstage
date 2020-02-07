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
end
