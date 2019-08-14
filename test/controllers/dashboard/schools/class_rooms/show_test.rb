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
      # Show, SchoolManager
      #
      test 'GET class_rooms#show as SchoolManager works' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
      end

      test 'GET class_rooms#show as SchoolManager shows student list' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        students = [
          create(:student, class_room: class_room, school: school, has_parental_consent: true),
          create(:student, class_room: class_room, school: school, custom_track: true),
          create(:student, class_room: class_room, school: school)
        ]
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_path(school, class_room)
        students.map do |student|
          assert_select 'a[href=?]', dashboard_students_internship_applications_path(student)
          if student.has_parental_consent?
            assert_select ".test-student-#{student.id} .has_parental_consent .fas.fa-square", 1
            assert_select ".test-student-#{student.id} .has_parental_consent .fas.fa-check", 1
            assert_select "a[href=?]", dashboard_school_user_path(school_id: student.school.id, id: student.id, user: { has_parental_consent: false })
          else
            assert_select ".test-student-#{student.id} .has_parental_consent .far.fa-square", 1
            assert_select "a[href=?]", "#approve-student-#{student.id}"
          end
          if student.custom_track?
            assert_select ".test-student-#{student.id} .is_custom_track .fas.fa-square", 1
            assert_select ".test-student-#{student.id} .is_custom_track .fas.fa-check", 1
            assert_select "a[href=?]", dashboard_school_user_path(school_id: student.school.id, id: student.id, user: { custom_track: false })
          else
            assert_select ".test-student-#{student.id} .is_custom_track .far.fa-square", 1
            assert_select "a[href=?]", dashboard_school_user_path(school_id: student.school.id, id: student.id, user: { custom_track: true })
          end
        end
      end

      #
      # Show, Other
      #
      test 'GET class_rooms#show as Other works' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        sign_in(create(:other, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
      end

      test 'GET class_rooms#show as Other shows student list' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        students = [
          create(:student, class_room: class_room, school: school),
          create(:student, class_room: class_room, school: school),
          create(:student, class_room: class_room, school: school)
        ]
        sign_in(create(:other, school: school))

        get dashboard_school_class_room_path(school, class_room)
        students.map do |student|
          assert_select 'a[href=?]', dashboard_students_internship_applications_path(student)
          if student.has_parental_consent?
            assert_select ".test-student-#{student.id} .fas.fa-check", 1
          else
            assert_select ".test-student-#{student.id} .fas.fa-times", 1
          end
        end
      end

      #
      # Show, MainTeacher
      #
      test 'GET class_rooms#show as MainTeacher works' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        sign_in(create(:main_teacher, school: school, class_room: class_room))

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
      end

      test 'GET class_rooms#show as MainTeacher shows student list' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        students = [
          create(:student, class_room: class_room, school: school, has_parental_consent: true),
          create(:student, class_room: class_room, school: school, has_parental_consent: false),
          create(:student, class_room: class_room, school: school, has_parental_consent: false)
        ]
        sign_in(create(:main_teacher, school: school, class_room: class_room))

        get dashboard_school_class_room_path(school, class_room)
        students.map do |student|
          if student.has_parental_consent?
            assert_select ".test-student-#{student.id} .fas.fa-check", 1
          else
            assert_select("#approve-student-#{student.id} a[href=?]",
                          dashboard_school_user_path(student.school, student, user: {has_parental_consent: true}))
          end
          student_stats = Presenters::StudentStats.new(student: student)
          assert_select ".test-student-#{student.id} span.applications_count",
                        text: student_stats.applications_count.to_s
          assert_select ".test-student-#{student.id} span.applications_approved_count",
                        text: student_stats.applications_approved_count.to_s
          # assert_select ".test-student-#{student.id} span.applications_with_convention_signed_count",
          #               text: student_stats.applications_with_convention_signed_count.to_s
        end
      end

      test 'GET class_rooms#show as MainTeacher contains key navigations links' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        sign_in(main_teacher)

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
        assert_select 'a.nav-link[href=?]', dashboard_school_class_rooms_path(school), count: 1
        assert_select 'a.nav-link[href=?]', dashboard_school_users_path(school), count: 0
        assert_select 'a.nav-link[href=?]', edit_dashboard_school_path(school), count: 0

        assert_select 'a.btn[href=?]', new_dashboard_school_class_room_path(school), count: 0
      end
    end
  end
end
