class SchoolManagerMailerPreview < ActionMailer::Preview

  def new_member
    SchoolManagerMailer.new_member(school_manager: school_manager,
                                   member: fetch_teacher)
  end

  def internship_application_approved_with_agreement_email
    SchoolManagerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: InternshipAgreement.first
    )
  end

  def internship_application_approved_with_no_agreement_email
    SchoolManagerMailer.internship_application_approved_with_no_agreement_email(
      internship_application: InternshipApplication.approved.first
    )
  end

  def notify_others_signatures_started_email
    SchoolManagerMailer.notify_others_signatures_started_email(
      internship_agreement: InternshipAgreement.first
    )
  end

  def notify_others_signatures_finished_email
    SchoolManagerMailer.notify_others_signatures_finished_email(
      internship_agreement: InternshipAgreement.first
    )
  end


  private

  def school_manager
    Users::SchoolManagement.find_by(role: 'school_manager')
  end

  def fetch_teacher
    Users::SchoolManagement.find_by(role: 'teacher')
  end

end
