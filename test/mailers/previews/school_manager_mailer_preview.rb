class SchoolManagerMailerPreview < ActionMailer::Preview
  def missing_school_weeks
    SchoolManagerMailer.missing_school_weeks(
      school_manager: Users::SchoolManager.first,
    )
  end

  def new_member
    SchoolManagerMailer.new_member(school_manager: Users::SchoolManager.first,
                                   member: Users::MainTeacher.first)
  end
end
