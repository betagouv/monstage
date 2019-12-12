class EmployerMailerPreview < ActionMailer::Preview
  def internship_applications_reminder_email
    employer = InternshipApplication.first
                                    .internship_offer
                                    .employer
    EmployerMailer.internship_applications_reminder_email(
      pending_applications: employer.internship_applications,
      rejected_applications: employer.internship_applications
    )
  end
end
