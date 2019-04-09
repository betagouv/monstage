require 'test_helper'


module Dashboard
  module Schools
    class UsersControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # destroy
      #
      test 'DELETE #destroy not signed in' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        main_teacher = create(:main_teacher, school: school)

        delete dashboard_school_user_path(school, main_teacher)
        assert_redirected_to new_user_session_path
      end

      test 'DELETE #destroy as main_teacher fails' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        main_teacher = create(:main_teacher, school: school)
        sign_in(main_teacher)
        delete dashboard_school_user_path(school, main_teacher)
        assert_redirected_to root_path
      end

      test 'DELETE #destroy as SchoolManager succeed' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        main_teacher = create(:main_teacher, school: school)
        sign_in(school_manager)
        assert_changes -> { main_teacher.reload.school } do
          delete dashboard_school_user_path(school, main_teacher)
        end
        assert_redirected_to dashboard_school_path(school)
      end

      #
      # update
      #
      test "PATCH #update as main teacher should approve parental consent" do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        main_teacher = create(:main_teacher, school: school)
        student = create(:student, school: school, has_parental_consent: false)

        sign_in(main_teacher)
        patch dashboard_school_user_path(school, student, params: { user: { has_parental_consent: true } }), headers: { "HTTP_REFERER" => root_path }

        assert student.reload.has_parental_consent
      end

      #
      # index
      #
      test 'GET show as Student is forbidden' do
        school = create(:school)
        sign_in(create(:student))

        get dashboard_school_users_path(school)
        assert_redirected_to root_path
      end

      test 'GET show as SchoolManager works' do
        school = create(:school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_users_path(school)
        assert_response :success
      end

      test 'GET show as SchoolManager contains key navigations links' do
        school = create(:school)
        sign_in(create(:school_manager, school: school))

        get dashboard_school_users_path(school)
        assert_response :success
        assert_select "a.nav-link[href=?]", dashboard_school_path(school)
        assert_select "a.disabled[href=?]", dashboard_school_users_path(school)
      end

      test 'GET show as SchoolManager contains list of main teachers' do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        sign_in(school_manager)
        school_employees = [
          create(:main_teacher, school: school),
          create(:teacher, school: school),
          create(:other, school: school)
        ]

        get dashboard_school_users_path(school)
        assert_response :success
        school_employees.each do |school_employee|
          assert_select "a[href=?]", dashboard_school_user_path(school, school_employee)
        end
      end
    end
  end
end
