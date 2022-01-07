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
        assert_redirected_to dashboard_school_users_path(school)
      end

      test 'PATCH #update as main teacher should change custom track' do
        school = create(:school, :with_school_manager)
        main_teacher = create(:main_teacher, school: school)
        student = create(:student, school: school, custom_track: false)

        sign_in(main_teacher)
        patch dashboard_school_user_path(school, student, params: { user: { custom_track: true } }), headers: { 'HTTP_REFERER' => root_path }

        assert student.reload.custom_track
      end

      #
      # index
      #
      test 'GET users#index as Student is forbidden' do
        school = create(:school)
        sign_in(create(:student))

        get dashboard_school_users_path(school)
        assert_redirected_to root_path
      end

      test 'GET users#index as SchoolManagement works' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)

        get dashboard_school_users_path(school)
        assert_response :success
      end

      test 'GET users#index as SchoolManagement contains key navigations links' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)

        get dashboard_school_users_path(school)
        assert_response :success
        assert_select 'title', "Professeurs du #{school.name} | Monstage"
        assert_select '.test-dashboard-nav a.nav-link[href=?]', dashboard_school_class_rooms_path(school), count: 1
        assert_select '.test-dashboard-nav a.active[href=?]', dashboard_school_users_path(school), count: 1
      end

      test 'GET users#index as SchoolManagement contains invitation modal link' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        get dashboard_school_users_path(school)

        assert_response :success
        assert_select ".test-modal-link",
                      text: "+ Inviter un membre du personnel"
      end

      test 'GET users#index as SchoolManagement contains list school members' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        school_employees = [
          create(:main_teacher, school: school),
          create(:teacher, school: school),
          create(:other, school: school)
        ]

        get dashboard_school_users_path(school)
        assert_response :success
        school_employees.each do |school_employee|
          assert_select 'a[href=?]', dashboard_school_user_path(school, school_employee)
        end
        assert_select '.test-presence-of-ux-guideline-invitation',
                      text: "Invitez les enseignants à s'inscrire, en leur communiquant simplement l'adresse du site.",
                      count: 0
      end
    end
  end
end
