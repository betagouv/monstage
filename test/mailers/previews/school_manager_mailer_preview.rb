class SchoolManagerMailerPreview < ActionMailer::Preview

  def new_member
    SchoolManagerMailer.new_member(school_manager: school_manager,
                                   member: fetch_teacher)
  end

  def agreement_creation_school_manager_notice_email
    SchoolManagerMailer.agreement_creation_notice_email(
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
