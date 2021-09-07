# frozen_string_literal: true

require 'application_system_test_case'

module W3c
  class DashboardTest < ApplicationSystemTestCase
    include Html5Validator
    include Devise::Test::IntegrationHelpers

    test 'USE_W3C, dashboard_internship_offers_path' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer)
      %i[drafted submitted approved rejected convention_signed].map do |aasm_state|
        create(:weekly_internship_application, aasm_state: aasm_state, internship_offer: internship_offer)
      end
      sign_in(employer)
      run_request_and_cache_response(report_as: 'dashboard_internship_offers_path') do
        visit dashboard_internship_offers_path
      end
    end

    test 'USE_W3C, edit_dashboard_internship_offer_path' do
      stage_dev = create(:weekly_internship_offer)
      sign_in(stage_dev.employer)
      run_request_and_cache_response(report_as: 'edit_dashboard_internship_offer_path') do
        visit edit_dashboard_internship_offer_path(id: stage_dev.to_param)
      end
    end


    test 'USE_W3C, new_dashboard_internship_offer_path(duplicate_id)' do
      stage_dev = create(:weekly_internship_offer)
      sign_in(stage_dev.employer)
      run_request_and_cache_response(report_as: 'new_dashboard_internship_offer_path') do
        visit new_dashboard_internship_offer_path(duplicate_id: stage_dev.id)
      end
    end

    test 'USE_W3C, custom_dashboard_path' do
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
          visit user.custom_dashboard_path
        end
      end
    end

    test 'USE_W3C, employer dashboard_internship_applications_path' do
      internship_application = create(:weekly_internship_application, :approved)
      sign_in(internship_application.internship_offer.employer)
      run_request_and_cache_response(report_as: 'dashboard_internship_applications_path') do
        visit dashboard_internship_applications_path
      end
    end

    test 'USE_W3C, school_manager dashboard_school_internship_applications_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room)
      internship_application = create(:weekly_internship_application, :approved, student: student)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'dashboard_school_internship_applications_path') do
        visit dashboard_school_internship_applications_path(school)
      end
    end

    test 'USE_W3C, school_manager dashboard_school_users_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      create(:teacher, school: school)
      create(:main_teacher, school: school)
      create(:other, school: school)

      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'school_manager dashboard_school_users_path') do
        visit dashboard_school_users_path(school)
      end
    end

    test 'USE_W3C, school_manager dashboard_school_class_rooms_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      create(:class_room, school: school)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'school_manager dashboard_school_class_rooms_path') do
        visit dashboard_school_class_rooms_path(school)
      end
    end

    test 'USE_W3C, school_manager edit_dashboard_school_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'school_manager edit_dashboard_school_path') do
        visit edit_dashboard_school_path(school)
      end
    end

    test 'USE_W3C, teacher dashboard_school_class_room_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      teacher = create(:teacher, school: school_manager.school)
      class_room = create(:class_room, school: school)
      sign_in(teacher)
      run_request_and_cache_response(report_as: 'school_manager dashboard_school_class_room_path') do
        visit dashboard_school_class_room_path(school, class_room)
      end
    end
  end
end
