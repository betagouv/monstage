# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class StudentsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # update by group
      #
      test 'PATCH students as SchoolManagement change class room' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        class_room_1 = create(:class_room, school: school)
        class_room_2 = create(:class_room, school: school)
        student_1 = create(:student, school: school, class_room: nil)
        student_2 = create(:student, school: school, class_room: nil)
        student_3 = create(:student, school: school, class_room: nil)
        
        put dashboard_school_update_students_by_group_path(school.id),
          params: { 
            "student_#{student_1.id}": class_room_1.id,
            "student_#{student_2.id}": class_room_2.id,
            "student_#{student_3.id}": ''
         }
        
        assert_equal class_room_1.id, student_1.reload.class_room_id
        assert_equal class_room_2.id, student_2.reload.class_room_id
        assert_equal nil, student_3.reload.class_room_id
      end
    end
  end
end
