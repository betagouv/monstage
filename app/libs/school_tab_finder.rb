# frozen_string_literal: true

class SchoolTabFinder
  def approved_application_count
    @application_count ||= school.internship_applications.with_active_students.approved.count
  end

  def student_without_class_room_count
    @students_without_classs_room_count ||= school.students.without_class_room.count
  end

  private
  attr_reader :school


  def initialize(school:)
    @school = school
  end
end
