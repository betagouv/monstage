class StudentMailerPreview < ActionMailer::Preview
  def internship_application_approved_email
    create_internship_application(aasm_state: :approved)
    internship_application = InternshipApplication.approved.first
    StudentMailer.internship_application_approved_email(
      internship_application: internship_application
    )
  end

  def internship_application_rejected_email
    create_internship_application(aasm_state: :rejected)
    internship_application = InternshipApplication.rejected.first
    StudentMailer.internship_application_rejected_email(
      internship_application: internship_application
    )
  end

  def internship_application_canceled_by_employer_email
    create_internship_application(aasm_state: :canceled_by_employer)
    internship_application = InternshipApplication.canceled_by_employer.first
    StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )
  end

  private

  def create_internship_application(aasm_state:)
    student          = FactoryBot.create(:student , email: "perfect_student-#{rand(1..10_000)}@ms3e.fr")
    employer         = FactoryBot.create(:employer, email: "perfect_employer-#{rand(1..10_000)}@ms3e.fr")
    internship_offer = FactoryBot.create(:weekly_internship_offer, employer: employer)
    FactoryBot.create(:weekly_internship_application, aasm_state, student: student, internship_offer: internship_offer )
  end
end
