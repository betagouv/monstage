# frozen_string_literal: true

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
    %i[employer
       student
       school_manager].each do |role|
      run_request_and_cache_response(report_as: "internship_offers_path_#{role}") do
        sign_in(create(role))
        get internship_offers_path
      end
    end
  end

  test 'internship_offer_path' do
    %i[employer student].each do |role|
      run_request_and_cache_response(report_as: "internship_offer_path_#{role}") do
        sign_in(create(role))
        get internship_offer_path(create(:internship_offer).to_param)
      end
    end
  end

  test 'new_internship_offer_path' do
    sign_in(create(:employer))
    run_request_and_cache_response(report_as: 'new_dashboard_internship_offer_path') do
      get new_dashboard_internship_offer_path
    end
  end

  test 'dashboard_internship_offers_path' do
    employer = create(:employer)
    2.times.map { create(:internship_offer, employer: employer) }
    sign_in(employer)
    run_request_and_cache_response(report_as: 'dashboard_internship_offers_path') do
      get dashboard_internship_offers_path
    end
  end

  test 'edit_internship_offer_path' do
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

  test 'account_path' do
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
      end
    end
  end

  test 'custom_dashboard_path' do
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
        get user.custom_dashboard_path
      end
    end
  end

  test 'static pages' do
    %i[
      root_path
      les_10_commandements_d_une_bonne_offre_path
      exemple_offre_ideale_ministere_path
      exemple_offre_ideale_sport_path
      qui_sommes_nous_path
      partenaires_path
      mentions_legales_path
      conditions_d_utilisation_path
      contact_path
      accessibilite_path
    ].map do |page_path|
      run_request_and_cache_response(report_as: page_path.to_s) do
        path = Rails.application.routes.url_helpers.send(page_path)
        get path
      end
    end
  end
end
