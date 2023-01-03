# frozen_string_literal: true

module Presenters
  # class or null object which avoids .try(:attribute) || 'default'
  module ClassRoom
    def self.or_null(class_room)
      return class_room if class_room

      Null.instance
    end



    def self.from_school(school)
      school.class_rooms
            .order(:name)
    end

    def self.students_without_class_room(school)
      school.students
            .includes(:school)
            .without_class_room
    end

    class Null
      include Singleton
      def id
        'nil-class-room'
      end

      def name
        'Sans classe'
      end
    end
  end
end
