require 'test_helper'


module Dashboard
  module Schools
    class UsersControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

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
        assert_redirected_to account_path
      end

      test "PATCH #update as main teacher should approve parental consent" do
        school = create(:school)
        school_manager = create(:school_manager, school: school)
        main_teacher = create(:main_teacher, school: school)
        student = create(:student, school: school, has_parental_consent: false)

        sign_in(main_teacher)
        patch dashboard_school_user_path(school, student, params: { user: { has_parental_consent: true } }), headers: { "HTTP_REFERER" => root_path }

        assert student.reload.has_parental_consent
      end
    end
  end
end
