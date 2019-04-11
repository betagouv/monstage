module Presenters
  class ClassRoomStats
    def total_student
      class_room.students.size
    end

    def total_student_with_parental_consent
      class_room.students
                .select(&:has_parental_consent?)
                .size
    end

    def total_student_with_zero_application
      class_room.students
                .select(&:has_zero_internship_application?)
                .size
    end

    def total_pending_convention_signed
      class_room.students
                .reject(&:has_convention_signed_internship_application?)
                .select(&:has_approved_internship_application?)
                .size
    end

    def total_student_with_zero_internship
      "- ? -"
    end

    private
    attr_reader :class_room
    def initialize(class_room:)
      @class_room = class_room
    end
  end
end
