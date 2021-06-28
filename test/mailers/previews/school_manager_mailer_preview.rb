class SchoolManagerMailerPreview < ActionMailer::Preview
  def missing_school_weeks
    SchoolManagerMailer.missing_school_weeks(
      school_manager: school_manager
    )
  end

  def new_member
    SchoolManagerMailer.new_member(school_manager: school_manager,
                                   member: fetch_teacher)
  end

  private

  def school_manager
    Users::SchoolManagement.find_by(role: 'school_manager')
  end

  def fetch_teacher
    Users::SchoolManagement.find_by(role: 'teacher')
  end

end
