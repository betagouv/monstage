# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class IndexClassRoomsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # Index Student
      #
      test 'GET class_rooms#index as Student is forbidden' do
        school = create(:school)
        sign_in(create(:student, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_redirected_to root_path
      end

      #
      # Index, SchoolManager
      #
      test 'GET class_rooms#index as SchoolManager works' do
        school = create(:school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_response :success
      end

      test 'GET class_rooms#index as SchoolManager ' \
           'contains key navigations links' do
        school = create(:school, :with_school_manager)
        class_room_with_student = create(:class_room, school: school,
                                                      students: [create(:student)])
        class_room_without_student = create(:class_room, school: school,
                                                         students: [])
        sign_in(school.school_manager)

        get dashboard_school_class_rooms_path(school)
        assert_response :success
        # navbar links
        assert_select '.navbar a.nav-link.active[href=?]',
                      dashboard_school_class_rooms_path(school), count: 1
        assert_select 'a.nav-link[href=?]',
                      dashboard_school_users_path(school), count: 1
        assert_select 'a.nav-link[href=?]',
                      edit_dashboard_school_path(school), count: 1

        # new link
        assert_select 'a.btn[href=?]',
                      new_dashboard_school_class_room_path(school), count: 1

        # destroy links
        assert_select 'a.float-right[href=?]',
                      dashboard_school_class_room_path(school, class_room_without_student),
                      count: 1
        assert_select 'a.float-right[href=?]',
                      dashboard_school_class_room_path(school, class_room_with_student),
                      count: 0 # do not show destroy on classrooms with students
        # edit links
        assert_select 'a.float-right[href=?]',
                      edit_dashboard_school_class_room_path(school, class_room_without_student),
                      count: 1
        assert_select 'a.float-right[href=?]',
                      edit_dashboard_school_class_room_path(school, class_room_with_student),
                      count: 1
      end

      test 'GET class_rooms#index as SchoolManager ' \
           'shows class rooms list' do
        school = create(:school)
        class_rooms = [
          create(:class_room, school: school),
          create(:class_room, school: school),
          create(:class_room, school: school)
        ]
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_rooms_path(school)
        class_rooms.map do |class_room|
          assert_select '.d-sm-none a[href=?]',
                        dashboard_school_class_room_path(school, class_room),
                        count: 1, text: 'Voir le détail'
          assert_select '.col-sm-12 a[href=?]',
                        dashboard_school_class_room_path(school, class_room),
                        count: 1, text: class_room.name

          stats = Presenters::ClassRoomStats.new(class_room: class_room)
          assert_select ".test-class-room-#{class_room.id} .total_student",
                        text: stats.total_student.to_s
          assert_select ".test-class-room-#{class_room.id} .total_student_with_parental_consent",
                        text: stats.total_student_with_parental_consent.to_s
          assert_select ".test-class-room-#{class_room.id} .total_student_with_zero_application",
                        text: stats.total_student_with_zero_application.to_s
          assert_select ".test-class-room-#{class_room.id} .total_pending_convention_signed",
                        text: stats.total_pending_convention_signed.to_s
          assert_select ".test-class-room-#{class_room.id} .total_student_with_zero_internship",
                        text: stats.total_student_with_zero_internship.to_s
        end
      end

      #
      # Index, Other
      #
      test 'GET class_rooms#index as Other works' do
        school = create(:school, :with_school_manager)
        sign_in(create(:other, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_response :success
      end

      test 'GET class_rooms#index as Other contains key navigations links' do
        school = create(:school, :with_school_manager)
        sign_in(create(:other, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_response :success
        assert_select '.navbar a.nav-link.active[href=?]',
                      dashboard_school_class_rooms_path(school),
                      count: 1
        assert_select 'a.nav-link[href=?]',
                      dashboard_school_users_path(school),
                      count: 1

        assert_select 'a.nav-link[href=?]',
                      edit_dashboard_school_path(school),
                      count: 0
        assert_select 'a.btn[href=?]',
                      new_dashboard_school_class_room_path(school),
                      count: 0
      end

      test 'GET class_rooms#index as Other shows class rooms list' do
        school = create(:school, :with_school_manager)
        class_rooms = [
          create(:class_room, school: school),
          create(:class_room, school: school),
          create(:class_room, school: school)
        ]
        sign_in(create(:other, school: school))

        get dashboard_school_class_rooms_path(school)
        class_rooms.map do |class_room|
          assert_select '.d-sm-none a[href=?]',
                        dashboard_school_class_room_path(school, class_room),
                        count: 1, text: 'Voir le détail'
          assert_select '.col-sm-12 a[href=?]',
                        dashboard_school_class_room_path(school, class_room),
                        count: 1, text: class_room.name
          assert_select 'a[href=?]',
                        edit_dashboard_school_class_room_path(school,
                                                              class_room),
                        count: 0
        end
      end

      #
      # Index, MainTeacher
      #
      test 'GET class_rooms#index as MainTeacher works' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school,
                                             class_room: class_room)
        sign_in(main_teacher)

        get dashboard_school_class_rooms_path(school)
        assert_response :success
      end

      test 'GET class_rooms#index as MainTeacher contains key navigations links' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school,
                                             class_room: class_room)
        sign_in(main_teacher)

        get dashboard_school_class_rooms_path(school)
        assert_response :success
        assert_select 'a.nav-link.active[href=?]',
                      dashboard_school_class_rooms_path(school),
                      count: 1
        assert_select 'a.nav-link[href=?]',
                      dashboard_school_users_path(school),
                      count: 0
        assert_select 'a.nav-link[href=?]',
                      edit_dashboard_school_path(school),
                      count: 0

        assert_select 'a.btn[href=?]', new_dashboard_school_class_room_path(school), count: 0
      end

      test 'GET class_rooms#index as MainTeacher shows class rooms list' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        class_rooms = [
          create(:class_room, school: school),
          create(:class_room, school: school),
          create(:class_room, school: school)
        ]
        sign_in(main_teacher)
        get dashboard_school_class_rooms_path(school)

        class_rooms.map do |class_room|
          assert_select '.d-sm-none a[href=?]',
                        dashboard_school_class_room_path(school, class_room),
                        count: 1, text: 'Voir le détail'
          assert_select '.col-sm-12 a[href=?]',
                        dashboard_school_class_room_path(school, class_room),
                        count: 1, text: class_room.name
          assert_select 'a[href=?]', edit_dashboard_school_class_room_path(school, class_room), count: 0
        end
      end
    end
  end
end
