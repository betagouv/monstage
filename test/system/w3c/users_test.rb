# frozen_string_literal: true

require 'application_system_test_case'

module W3c
  class UsersTest < ApplicationSystemTestCase
    include Html5Validator
    include Devise::Test::IntegrationHelpers

    test 'USE_W3C, register as Employer' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Employer') do
        visit new_user_registration_path(as: 'Employer')
      end
    end

    test 'USE_W3C, register as SchoolManagement' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_SchoolManagement') do
        visit new_user_registration_path(as: 'SchoolManagement')
      end
    end

    test 'USE_W3C, register as Student' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Student') do
        visit new_user_registration_path(as: 'Student')
      end
    end

    test 'USE_W3C, register as Operator' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Operator') do
        visit new_user_registration_path(as: 'Operator')
      end
    end

    test 'USE_W3C, register as Statistician' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Statistician') do
        visit new_user_registration_path(as: 'Statistician')
      end
    end

    test 'USE_W3C, sign in' do
      run_request_and_cache_response(report_as: 'new_user_session_path') do
        visit new_user_session_path
      end
    end

    test 'USE_W3C, new password' do
      run_request_and_cache_response(report_as: 'new_user_password') do
        visit new_user_password_path
      end
    end

    test 'USE_W3C, new_user_confirmation' do
      run_request_and_cache_response(report_as: 'new_user_confirmation') do
        visit new_user_confirmation_path
      end
    end

    test 'USE_W3C, users_choose_profile' do
      run_request_and_cache_response(report_as: 'users_choose_profile') do
        visit users_choose_profile_path
      end
    end

    test 'USE_W3C, edit_(:api)' do
      operator = create(:user_operator)
      sign_in(operator)
      run_request_and_cache_response(report_as: 'edit_api') do
        visit account_path(section: :api)
      end
    end

    test 'USE_W3C, edit_(:identiy)' do
      school = create(:school, :with_school_manager)
      teacher = create(:teacher, school: school)
      sign_in(teacher)
      run_request_and_cache_response(report_as: 'edit_identiy') do
        visit account_path(section: :identity)
      end
    end

    test 'USE_W3C, edit_(:resume)' do
      student = create(:student)
      sign_in(student)
      run_request_and_cache_response(report_as: 'edit_resume') do
        visit account_path(section: :resume)
      end
    end
    test 'USE_W3C, edit_(:school)' do
      school_manager = create(:school_manager)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'edit_school') do
        visit account_path(section: :school)
      end
    end

    test 'USE_W3C, account_path default' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      [
        create(:employer),
        create(:student),
        school_manager,
        create(:teacher, school: school_manager.school),
        create(:main_teacher, school: school_manager.school),
        create(:other, school: school_manager.school)
      ].each do |user|
        role = user.class.name.demodulize.downcase
        report_as = "custom_dashboard_path_#{role}"

        run_request_and_cache_response(report_as: report_as) do
          sign_in(user)
          visit account_path
        end
      end
    end
  end
end
