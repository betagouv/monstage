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
    end
  end
end
