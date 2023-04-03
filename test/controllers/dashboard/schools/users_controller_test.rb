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
        school = create(:school, :with_school_manager,:with_weeks)
        sign_in(school.school_manager)

        get dashboard_school_users_path(school)
        assert_response :success
        assert_select 'title', "Professeurs du #{school.presenter.school_name_in_sentence} | Monstage"
        assert_select 'ul.fr-tabs__list li a[href=?]', dashboard_school_class_rooms_path(school), count: 1
        assert_select 'ul.fr-tabs__list li a[href=?]', dashboard_school_users_path(school), count: 1
        assert_select 'ul.fr-tabs__list li a[href=?] button[aria-selected="false"]', dashboard_school_class_rooms_path(school), count: 1
        assert_select 'ul.fr-tabs__list li a[href=?] button[aria-selected="true"]', dashboard_school_users_path(school), count: 1
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
