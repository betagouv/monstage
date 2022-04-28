# frozen_string_literal: true

module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool
      include NestedClassRoom

      def show
        @student = @class_room.students.find(params[:id])
        authorize! :show_user_in_school, @student
      end

      def index
        @students = @class_room.students
                               .includes([:school, :internship_applications])
                               .order(:last_name, :first_name)
      end
    end
  end
end
