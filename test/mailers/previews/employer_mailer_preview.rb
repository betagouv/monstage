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
    student          = FactoryBot.create(:student , email: "perfect_student-#{rand(1..1000)}@ms3e.fr")
    employer         = FactoryBot.create(:employer, email: "perfect_employer-#{rand(1..1000)}@ms3e.fr")
    internship_offer = FactoryBot.create(:weekly_internship_offer, employer: employer)
    FactoryBot.create(:weekly_internship_application,:approved, student: student, internship_offer: internship_offer )
    internship_application = InternshipApplication&.approved&.first
    internship_application.canceled_by_student_message.body = "J'ai trouvé mieux ailleurs, sorry mate"
    EmployerMailer.internship_application_canceled_by_student_email(
      internship_application: internship_application
    )
  end
end
