# frozen_string_literal: true

class SchoolTabFinders
  def application_count
    @application_count ||= school.internship_applications.approved.count
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
