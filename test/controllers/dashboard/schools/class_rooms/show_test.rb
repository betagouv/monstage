# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class ShowClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Student
      #
      test 'GET class_rooms#show as Student is forbidden' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        sign_in(create(:student, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_redirected_to root_path
      end

      #
      # Show, SchoolManagement
      #
      test 'GET class_rooms#show as SchoolManagement shows student list' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        students = [
          create(:student, class_room: class_room, school: school, confirmed_at: 2.days.ago),
          create(:student, class_room: class_room, school: school, custom_track: true),
          create(:student, class_room: class_room, school: school)
        ]
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_path(school, class_room)
        students.map do |student|
          assert_select 'a[href=?]', dashboard_students_internship_applications_path(student)

          if student.confirmed?
            assert_select ".test-student-#{student.id} .student_confirmed .fas.fa-square", 1
            assert_select ".test-student-#{student.id} .student_confirmed .fas.fa-check", 1
          else
            assert_select ".test-student-#{student.id} .student_confirmed .far.fa-square", 1
          end

          if student.custom_track?
            assert_select ".test-student-#{student.id} .is_custom_track .fas.fa-square", 1
            assert_select ".test-student-#{student.id} .is_custom_track .fas.fa-check", 1
            assert_select 'a[href=?]', dashboard_school_user_path(school_id: student.school.id, id: student.id, user: { custom_track: false })
          else
            assert_select ".test-student-#{student.id} .is_custom_track .far.fa-square", 1
            assert_select 'a[href=?]', dashboard_school_user_path(school_id: student.school.id, id: student.id, user: { custom_track: true })
          end

          student_stats = Presenters::Dashboard::StudentStats.new(student: student)
          assert_select ".test-student-#{student.id} span.applications_count",
                        text: student_stats.applications_count.to_s
          assert_select ".test-student-#{student.id} span.applications_approved_count",
                        text: student_stats.applications_approved_count.to_s
        end
      end

      test 'GET class_rooms#show as SchoolManagement contains key navigations links' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        sign_in(main_teacher)

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
        assert_select 'a.nav-link[href=?]', dashboard_school_class_rooms_path(school), count: 1
        assert_select 'a.nav-link[href=?]', dashboard_school_users_path(school), count: 1
        assert_select 'a.nav-link[href=?]', edit_dashboard_school_path(school), count: 1
        assert_select 'li a.fr-link[href=?]', edit_dashboard_school_path(school), count: 1
        assert_select 'a.btn[href=?]', new_dashboard_school_class_room_path(school), count: 0
      end

      test 'GET class_rooms#show as SchoolManagement can remove student from school' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        student = create(:student, class_room: class_room, school: school, confirmed_at: 2.days.ago)
        sign_in(main_teacher)

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
        assert_select ".test-student-#{student.id} select option[value='']",
                      text: 'Cet élève ne fait pas partie de mon établissement'
      end
    end
  end
end
