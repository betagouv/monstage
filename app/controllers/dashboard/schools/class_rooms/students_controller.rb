module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool
      include NestedClassRoom

      def show
        @student = @class_room.students.find(params[:id])
      end
    end
  end
end
