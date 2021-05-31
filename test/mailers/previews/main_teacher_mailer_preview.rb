# frozen_string_literal: true

class MainTeacherMailerPreview < ActionMailer::Preview
  def internship_application_approved_email
    internship_application = create_internship_application(aasm_state: :approved)

    MainTeacherMailer.internship_application_approved_email(
      internship_application: internship_application,
      main_teacher: create_or_fetch_main_teacher(internship_application)
    )
  end

  private

  def create_or_fetch_main_teacher(internship_application)
    school = internship_application.student.school
    return school.main_teachers.first if school.main_teachers.present?

    FactoryBot.create(
      :school_manager,
      school: school,
      email: "perfect-school-manager-#{rand(1..1_000)}@ac-paris.fr"
    )
    FactoryBot.create(
      :main_teacher,
      school: school,
      email: "perfect-teacher-#{rand(1..1_000)}@ms3e.fr"
    )
  end

  def create_internship_application(aasm_state:)
    student          = FactoryBot.create(:student , email: "perfect_student-#{rand(1..10_000)}@ms3e.fr")
    employer         = FactoryBot.create(:employer, email: "perfect_employer-#{rand(1..10_000)}@ms3e.fr")
    internship_offer = FactoryBot.create(:weekly_internship_offer, employer: employer)
    FactoryBot.create(:weekly_internship_application, aasm_state, student: student, internship_offer: internship_offer )
  end
end
