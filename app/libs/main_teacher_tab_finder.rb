# frozen_string_literal: true

class MainTeacherTabFinder
  def approved_application_count
    @application_count ||= InternshipApplication.with_active_students
                                                .approved
                                                .through_teacher(teacher: main_teacher)
                                                .count
  end

  def student_without_class_room_count
    return 0 if school.nil?

    @students_without_classs_room_count ||= school.students.without_class_room.count
  end

  private
  attr_reader :main_teacher, :school


  def initialize(main_teacher:)
    @main_teacher = main_teacher
    @school = main_teacher.try(:school)
  end
end
