# frozen_string_literal: true

module Presenters
  module Dashboard
    class ClassRoomStats
      def total_student
        class_room.students.kept.size
      end

      def total_student_confirmed
        class_room.students.kept
                  .select(&:confirmed?)
                  .size
      end

      def total_student_with_zero_application
        class_room.students.kept
                  .select(&:has_zero_internship_application?)
                  .size
      end

      def total_student_with_zero_internship
        class_room.students.kept
                  .includes([:internship_applications])
                  .reject(&:has_convention_signed_internship_application?)
                  .size
      end

      private

      attr_reader :class_room
      def initialize(class_room:)
        @class_room = class_room
      end
    end
  end
end
