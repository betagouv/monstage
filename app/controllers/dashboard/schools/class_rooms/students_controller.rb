# frozen_string_literal: true

module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool
      include NestedClassRoom

      def index
        @students = @class_room.students
                               .includes([:school, :internship_applications])
                               .order(:last_name, :first_name)
      end
    end
  end
end
