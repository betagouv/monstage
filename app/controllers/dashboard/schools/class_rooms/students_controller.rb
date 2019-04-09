module Dashboard
  module Schools::ClassRooms
    class StudentsController < ApplicationController
      include NestedSchool
      # include NestedClassRoom
    end
  end
end
