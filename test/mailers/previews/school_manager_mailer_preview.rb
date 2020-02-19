# frozen_string_literal: true

class SchoolManagerMailerPreview < ActionMailer::Preview
  def missing_school_weeks
    SchoolManagerMailer.missing_school_weeks(
      school_manager: School.where(name: 'Pasteur').first.school_manager
    )
  end
end
