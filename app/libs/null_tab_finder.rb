# frozen_string_literal: true

class NullTabFinder
  def approved_application_count
    @application_count ||= 0
  end

  def student_without_class_room_count
    @students_without_classs_room_count ||= 0
  end
end
