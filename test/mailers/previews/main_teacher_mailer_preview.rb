# frozen_string_literal: true

class MainTeacherMailerPreview < ActionMailer::Preview
  def internship_application_approved_with_agreement_email
    internship_application = InternshipApplication&.approved&.first

    MainTeacherMailer.internship_application_approved_with_agreement_email(
      internship_application: internship_application,
      main_teacher: fetch_main_teacher(internship_application)
    )
  end

  def internship_application_approved_with_no_agreement_email
    internship_application = InternshipApplication&.approved&.first

    MainTeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      main_teacher: fetch_main_teacher(internship_application)
    )
  end

  def internship_application_approved_with_no_agreement_email
    internship_application = InternshipApplication&.approved&.first

    MainTeacherMailer.internship_application_approved_with_no_agreement_email(
      internship_application: internship_application,
      main_teacher: fetch_main_teacher(internship_application)
    )
  end

  private

  def fetch_main_teacher(internship_application)
    school = internship_application.student.school
    return school.main_teachers.first if school.main_teachers.present?
  end

end
