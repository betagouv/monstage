# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools::ClassRooms
    class StudentsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Show
      #
      test 'GET show as Student is forbidden' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        sign_in(student)

        get dashboard_school_class_room_student_path(school, class_room, student)
        assert_redirected_to root_path
      end

      test 'GET show as SchoolManagement works' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_student_path(school, class_room, student)
        assert_response :success
      end
    end
  end
end
