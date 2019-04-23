require 'test_helper'

class HomeValidationTest < ActionDispatch::IntegrationTest
  include Html5Validator
  include Devise::Test::IntegrationHelpers

  test 'root_path' do
    run_request_and_cache_response(report_as: 'root_path') do
      get root_path
    end
  end

  test 'internship_offers_path' do
    sign_in(create(:employer))
    run_request_and_cache_response(report_as: 'internship_offers_path') do
      get internship_offers_path
    end
  end

  test 'internship_offer_path' do
    run_request_and_cache_response(report_as: 'internship_offer_path') do
      get internship_offer_path(create(:internship_offer).to_param)
    end
  end

  test 'new_internship_offer_path'  do
    sign_in(create(:employer))
    run_request_and_cache_response(report_as: 'new_dashboard_internship_offer') do
      get new_dashboard_internship_offer_path
    end
  end

  test 'edit_internship_offer_path'  do
    stage_dev = create(:internship_offer)
    sign_in(stage_dev.employer)
    run_request_and_cache_response(report_as: 'edit_dashboard_internship_offer_path') do
      get edit_dashboard_internship_offer_path(id: stage_dev.to_param)
    end
  end

  test 'register as Employer' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_Employer') do
      get new_user_registration_path(as: 'Employer')
    end
  end

  test 'register as MainTeacher' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_MainTeacher') do
      get new_user_registration_path(as: 'MainTeacher')
    end
  end

  test 'register as Other' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_Other') do
      get new_user_registration_path(as: 'Other')
    end
  end

  test 'register as SchoolManager' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_SchoolManager') do
      get new_user_registration_path(as: 'SchoolManager')
    end
  end

  test 'register as Student' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_Student') do
      get new_user_registration_path(as: 'Student')
    end
  end

  test 'register as Teacher' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_Teacher') do
      get new_user_registration_path(as: 'Teacher')
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

  test 'static pages' do
    [
      :root_path,
      :les_10_commandements_d_une_bonne_offre_path,
      :exemple_offre_ideale_ministere_path,
      :exemple_offre_ideale_sport_path
    ].map do |page_path|
      run_request_and_cache_response(report_as: page_path.to_s) do
        path = Rails.application.routes.url_helpers.send(page_path)
        get path
      end
    end
  end
end
