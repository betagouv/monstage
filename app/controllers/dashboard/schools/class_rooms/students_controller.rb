# frozen_string_literal: true

module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool

      def index
        authorize! :manage_school_students, current_user.school

        @class_room = @school.class_rooms.find(params.require(:class_room_id))
        @students = @class_room.students
                               .includes([:school, :internship_applications])
                               .order(:last_name, :first_name)
      end
    end
  end
end
