# frozen_string_literal: true

require 'test_helper'
module W3c
  class UsersTest < ActionDispatch::IntegrationTest
    include Html5Validator
    include Devise::Test::IntegrationHelpers

    test 'register as Employer' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Employer') do
        get new_user_registration_path(as: 'Employer')
        assert_response :success
      end
    end

    test 'register as MainTeacher' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_MainTeacher') do
        get new_user_registration_path(as: 'MainTeacher')
        assert_response :success
      end
    end

    test 'register as Other' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Other') do
        get new_user_registration_path(as: 'Other')
        assert_response :success
      end
    end

    test 'register as SchoolManager' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_SchoolManager') do
        get new_user_registration_path(as: 'SchoolManager')
        assert_response :success
      end
    end

    test 'register as Student' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Student') do
        get new_user_registration_path(as: 'Student')
        assert_response :success
      end
    end

    test 'register as Teacher' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Teacher') do
        get new_user_registration_path(as: 'Teacher')
        assert_response :success
      end
    end
    test 'register as Operator' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Operator') do
        get new_user_registration_path(as: 'Operator')
        assert_response :success
      end
    end
    test 'register as Statistician' do
      run_request_and_cache_response(report_as: 'new_user_registration_path_Statistician') do
        get new_user_registration_path(as: 'Statistician')
        assert_response :success
      end
    end

    test 'sign in' do
      run_request_and_cache_response(report_as: 'new_user_session_path') do
        get new_user_session_path
      end
    end

    test 'new password' do
      run_request_and_cache_response(report_as: 'new_user_password') do
        get new_user_password_path
      end
    end

    test 'new_user_confirmation' do
      run_request_and_cache_response(report_as: 'new_user_confirmation') do
        get new_user_confirmation_path
      end
    end

    test 'users_choose_profile' do
      run_request_and_cache_response(report_as: 'users_choose_profile') do
        get users_choose_profile_path
      end
    end

    test 'edit_(:api)' do
      operator = create(:user_operator)
      sign_in(operator)
      run_request_and_cache_response(report_as: 'users_choose_profile') do
        get account_path(section: :api)
        assert_response :success
      end
    end

    test 'edit_(:identiy)' do
      school = create(:school, :with_school_manager)
      teacher = create(:teacher, school: school)
      sign_in(teacher)
      run_request_and_cache_response(report_as: 'users_choose_profile') do
        get account_path(section: :identity)
        assert_response :success
      end
    end

    test 'edit_(:resume)' do
      student = create(:student)
      sign_in(student)
      run_request_and_cache_response(report_as: 'users_choose_profile') do
        get account_path(section: :resume)
        assert_response :success
      end
    end
    test 'edit_(:school)' do
      school_manager = create(:school_manager)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'users_choose_profile') do
        get account_path(section: :school)
        assert_response :success
      end
    end

    test 'account_path default' do
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
          get account_path
          assert_response :success, "fails for #{user.type}"
        end
      end
    end
  end
end
