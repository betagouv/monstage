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
        with_application_statuses = %i[submitted approved ]
        with_application = track_student_with_listed_status(listed_status: with_application_statuses)
        rest_of_class_room_size(reject_list: with_application)
      end

      def total_student_with_zero_internship
        with_internship_status = %i[approved ]
        with_internship = track_student_with_listed_status(listed_status: with_internship_status)
        rest_of_class_room_size(reject_list: with_internship)
      end

      private

      attr_reader :class_room
      def initialize(class_room:)
        @class_room = class_room
      end

      def track_student_with_listed_status(listed_status: [])
        Users::Student.kept
                      .joins(:class_room, :internship_applications)
                      .where(class_room: { id: class_room.id })
                      .where(internship_applications: { aasm_state: listed_status })

      end

      def rest_of_class_room_size(reject_list: )
        Users::Student.kept
                      .joins(:class_room)
                      .where(class_room: { id: class_room.id })
                      .where.not(id: reject_list.ids.uniq)
                      .size
      end
    end
  end
end
