require 'test_helper'

module Dashboard
  module Schools
    class ClassRoomsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # New, SchoolManager
      #
      test 'GET class_rooms#new as SchoolManager responds with success' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        class_room_name = SecureRandom.hex
        class_room = create(:class_room, name: class_room_name, school: school)
        sign_in(school_manager)

        get new_dashboard_school_class_room_path(school.to_param)

        assert_response :success
      end

      test 'GET class_rooms#new as Student responds with fail' do
        school = create(:school)
        student = create(:student)
        sign_in(student)
        get new_dashboard_school_class_room_path(school.to_param)
        assert_redirected_to root_path
      end

      #
      # Create, SchoolManager
      #
      test 'POST class_rooms#create as SchoolManager responds with success' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        sign_in(school_manager)
        class_room_name = SecureRandom.hex
        assert_difference 'ClassRoom.count' do
          post dashboard_school_class_rooms_path(school.to_param), params: { class_room: { name: class_room_name } }
          assert_redirected_to dashboard_school_class_rooms_path(school)
        end
        assert_equal 1, ClassRoom.where(name: class_room_name).count
      end

      test 'POST class_rooms#create as Student responds with fail' do
        student = create(:student)
        school = create(:school)
        sign_in(student)
        post dashboard_school_class_rooms_path(school.to_param), params: { class_room: {name: 'test'} }
        assert_redirected_to root_path
      end

      #
      # Edit, SchoolManager
      #
      test 'GET class_rooms#edit as SchoolManager render form' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        class_room = create(:class_room, school: school)

        sign_in(school_manager)
        get edit_dashboard_school_class_room_path(school.to_param, class_room.to_param)
        assert_response :success
      end

      #
      # Update, SchoolManager
      #
      test 'PATCH class_rooms#update as SchoolManager update class_room' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        class_room = create(:class_room, school: school, name: SecureRandom.hex)
        sign_in(school_manager)
        patch dashboard_school_class_room_path(school, class_room, params: {class_room: { name: 'new_name' }})
        assert_redirected_to dashboard_school_class_rooms_path
        assert_equal 'new_name', class_room.reload.name
      end

      #
      # Show, SchoolManager, MainTeacher
      #
      test 'GET class_rooms#show as Student is forbidden' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        sign_in(create(:student, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_redirected_to root_path
      end

      # Show, SchoolManager
      test 'GET class_rooms#show as SchoolManager works' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
      end

      # Show, SchoolManager
      test 'GET class_rooms#show as SchoolManager shows student list' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        students = [
          create(:student, class_room: class_room, school: school),
          create(:student, class_room: class_room, school: school),
          create(:student, class_room: class_room, school: school),
        ]
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_room_path(school, class_room)
        students.map do |student|
          assert_select "a[href=?]", dashboard_school_class_room_student_path(school, class_room, student)
          if student.has_parental_consent?
            assert_select ".test-student-#{student.id} .fas.fa-check", 1
          else
            assert_select ".test-student-#{student.id} .fas.fa-times", 1
          end
        end
      end

      # Show, MainTeacher
      test 'GET class_rooms#show as MainTeacher works' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        sign_in(create(:main_teacher, school: school, class_room: class_room))

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
      end

      # Show, MainTeacher
      test 'GET class_rooms#show as MainTeacher shows student list' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        students = [
          create(:student, class_room: class_room, school: school, has_parental_consent: true),
          create(:student, class_room: class_room, school: school, has_parental_consent: false),
          create(:student, class_room: class_room, school: school, has_parental_consent: false),
        ]
        sign_in(create(:main_teacher, school: school, class_room: class_room))

        get dashboard_school_class_room_path(school, class_room)
        students.map do |student|
          if student.has_parental_consent?
            assert_select ".test-student-#{student.id} .fas.fa-check", 1
          else
            assert_select(".test-student-#{student.id} form[action=?]",
                          dashboard_school_user_path(student.school, student))
          end
          student_stats = Presenters::StudentStats.new(student: student)
          assert_select ".test-student-#{student.id} span.applications_count",
                        text: student_stats.applications_count.to_s
          assert_select ".test-student-#{student.id} span.applications_approved_count",
                        text: student_stats.applications_approved_count.to_s
          assert_select ".test-student-#{student.id} span.applications_with_convention_pending_count",
                        text: student_stats.applications_with_convention_pending_count.to_s
          assert_select ".test-student-#{student.id} span.applications_with_convention_signed_count",
                        text: student_stats.applications_with_convention_signed_count.to_s
          assert_select ".test-student-#{student.id} span.internship_done",
                        text: student_stats.internship_done?.to_s
          assert_select ".test-student-#{student.id} span.internship_locations",
                        text: student_stats.internship_locations.to_s
          assert_select ".test-student-#{student.id} span.internship_tutors",
                        text: student_stats.internship_tutors.to_s
        end
      end

      test 'GET class_rooms#show as MainTeacher contains key navigations links' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        sign_in(main_teacher)

        get dashboard_school_class_room_path(school, class_room)
        assert_response :success
        assert_select "a.nav-link[href=?]", dashboard_school_class_rooms_path(school), count: 1
        assert_select "a.nav-link[href=?]", dashboard_school_users_path(school), count: 0
        assert_select "a.nav-link[href=?]", edit_dashboard_school_path(school), count: 0
        assert_select "a.btn[href=?]", new_dashboard_school_class_room_path(school), count: 0
      end


      #
      # Index, SchoolManager, MainTeacher
      #
      test 'GET class_rooms#index as Student is forbidden' do
        school = create(:school)
        sign_in(create(:student, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_redirected_to root_path
      end

      # Index, SchoolManager
      test 'GET class_rooms#index as SchoolManager works' do
        school = create(:school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_response :success
      end

      test 'GET class_rooms#index as SchoolManager contains key navigations links' do
        school = create(:school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_rooms_path(school)
        assert_response :success
        assert_select "a.nav-link.disabled[href=?]", dashboard_school_class_rooms_path(school), count: 1
        assert_select "a.nav-link[href=?]", dashboard_school_users_path(school), count: 1
        assert_select "a.nav-link[href=?]", edit_dashboard_school_path(school), count: 1

        assert_select "a.btn[href=?]", new_dashboard_school_class_room_path(school), count: 1
      end

      test 'GET class_rooms#index as SchoolManager shows class rooms list' do
        school = create(:school)
        class_rooms = [
          create(:class_room, school: school),
          create(:class_room, school: school),
          create(:class_room, school: school)
        ]
        sign_in(create(:school_manager, school: school))

        get dashboard_school_class_rooms_path(school)
        class_rooms.map do |class_room|
          assert_select 'a[href=?]',
                        dashboard_school_class_room_path(school, class_room),
                        count: 1
          assert_select 'a[href=?]',
                        edit_dashboard_school_class_room_path(school, class_room),
                        count: 1

          class_room_stats = Presenters::ClassRoomStats.new(class_room: class_room)
          assert_select ".test-class-room-#{class_room.id} span.total_student",
                        text: class_room_stats.total_student.to_s
          assert_select ".test-class-room-#{class_room.id} span.total_student_with_parental_consent",
                        text: class_room_stats.total_student_with_parental_consent.to_s
          assert_select ".test-class-room-#{class_room.id} span.total_student_with_zero_application",
                        text: class_room_stats.total_student_with_zero_application.to_s
          assert_select ".test-class-room-#{class_room.id} span.total_pending_convention_signed",
                        text: class_room_stats.total_pending_convention_signed.to_s
          assert_select ".test-class-room-#{class_room.id} span.total_student_with_zero_internship",
                        text: class_room_stats.total_student_with_zero_internship.to_s
        end
      end

      # Index, MainTeacher
      test 'GET class_rooms#index as MainTeacher works' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        sign_in(main_teacher)

        get dashboard_school_class_rooms_path(school)
        assert_response :success
      end

      test 'GET class_rooms#index as MainTeacher contains key navigations links' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        sign_in(main_teacher)

        get dashboard_school_class_rooms_path(school)
        assert_response :success
        assert_select "a.nav-link.disabled[href=?]", dashboard_school_class_rooms_path(school), count: 1
        assert_select "a.nav-link[href=?]", dashboard_school_users_path(school), count: 0
        assert_select "a.nav-link[href=?]", edit_dashboard_school_path(school), count: 0

        assert_select "a.btn[href=?]", new_dashboard_school_class_room_path(school), count: 0
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
          assert_select 'a[href=?]', dashboard_school_class_room_path(school, class_room), count: 1
          assert_select 'a[href=?]', edit_dashboard_school_class_room_path(school, class_room), count: 0
        end
      end
    end
  end
end
