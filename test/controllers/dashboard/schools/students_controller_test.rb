# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class StudentsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # index
      #
      test 'GET students#index as Student is forbidden' do
        school = create(:school)
        sign_in(create(:student))

        get dashboard_school_students_path(school)
        assert_redirected_to root_path
      end

      test 'GET students#index as SchoolManagement works' do
        school = create(:school, :with_school_manager)
        [
          create(:school_manager, school: school),
          create(:main_teacher, school: school),
          create(:other, school: school),
          create(:teacher, school: school)
        ].each do |role|
          sign_in(role)
          get dashboard_school_students_path(school)
          assert_response :success
        end
      end

      test 'GET students#index as SchoolManagement contains key navigations links' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)

        get dashboard_school_students_path(school)
        assert_response :success
        assert_select '.test-dashboard-nav a.active[href=?]', dashboard_school_students_path(school), count: 1
      end

      test 'GET students#index as SchoolManagement contains list school students' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        class_room_1 = create(:class_room, school: school)
        class_room_2 = create(:class_room, school: school)
        school_students = [
          create(:student, school: school, class_room: class_room_1),
          create(:student, school: school, class_room: class_room_2),
          create(:student, school: school, class_room: nil)
        ]

        get dashboard_school_students_path(school)
        assert_response :success
        school_students.each do |school_student|
          class_room = Presenters::ClassRoom.or_null(school_student.class_room)
          class_room_tbody_class_name = ".test-class-room-#{class_room.id}"
          assert_select(class_room_tbody_class_name) do
            assert_select ".test-student-#{school_student.id}"
          end
        end
      end

      #
      # update
      #
      test 'PATCH students as SchoolManagement change change class room' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        class_room_1 = create(:class_room, school: school)
        class_room_2 = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room_1)
        redirect_back = root_path
        assert_changes -> { student.reload.class_room_id },
                       from: class_room_1.id,
                       to: class_room_2.id do
          patch dashboard_school_student_path(
            school,
            student,
            params: { student: { class_room_id: class_room_2.id } }
          ),
                headers: { 'HTTP_REFERER' => redirect_back }
          assert_redirected_to redirect_back
        end
      end

      #
      # update by group
      #
      test 'PATCH students as SchoolManagement change class room by group' do
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
