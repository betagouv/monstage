# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class UsersControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # destroy
      #
      test 'DELETE #destroy not signed in' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)

        delete dashboard_school_user_path(school, main_teacher)
        assert_redirected_to new_user_session_path
      end

      test 'DELETE #destroy as main_teacher fails' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)
        sign_in(main_teacher)
        delete dashboard_school_user_path(school, main_teacher)
        assert_redirected_to root_path
      end

      test 'DELETE #destroy as SchoolManagement succeed' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)
        sign_in(school.school_manager)
        assert_changes -> { main_teacher.reload.school } do
          delete dashboard_school_user_path(school, main_teacher)
        end
      end

      test 'PATCH #update as main teacher should change custom track' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)
        student = create(:student, school: school, custom_track: false)

        sign_in(main_teacher)
        patch dashboard_school_user_path(school, student, params: { user: { custom_track: true } }), headers: { 'HTTP_REFERER' => root_path }

        assert student.reload.custom_track
      end
    end
  end
end
