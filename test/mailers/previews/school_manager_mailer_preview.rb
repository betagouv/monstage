class SchoolManagerMailerPreview < ActionMailer::Preview
  def missing_school_weeks
    SchoolManagerMailer.missing_school_weeks(
      school_manager: Users::SchoolManagement.school_managers.first
    )
  end

  def new_member
    SchoolManagerMailer.new_member(school_manager: Users::SchoolManagement.school_managers.first,
                                   member: Users::SchoolManagement.teachers.first)
  end
end
