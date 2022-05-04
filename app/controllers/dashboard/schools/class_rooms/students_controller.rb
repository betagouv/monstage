# frozen_string_literal: true

module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool
      include NestedClassRoom

      def index
        authorize! :manage_school_students, current_user.school
        @students = @class_room.students
                               .includes([:school, :internship_applications])
                               .order(:last_name, :first_name)
      end
    end
  end
end
