# frozen_string_literal: true

require 'application_system_test_case'

module W3c
  class DashboardTest < ApplicationSystemTestCase
    include Html5Validator
    include Devise::Test::IntegrationHelpers

    test 'dashboard_internship_offers_path' do
      employer = create(:employer)
      internship_offer = create(:internship_offer, employer: employer)
      %i[drafted submitted approved rejected convention_signed].map do |aasm_state|
        create(:internship_application, :weekly, aasm_state: aasm_state, internship_offer: internship_offer)
      end
      sign_in(employer)
      run_request_and_cache_response(report_as: 'dashboard_internship_offers_path') do
        visit dashboard_internship_offers_path
      end
    end

    test 'edit_dashboard_internship_offer_path' do
      stage_dev = create(:internship_offer)
      sign_in(stage_dev.employer)
      run_request_and_cache_response(report_as: 'edit_dashboard_internship_offer_path') do
        visit edit_dashboard_internship_offer_path(id: stage_dev.to_param)
      end
    end

    test 'new_dashboard_internship_offer_path' do
      employer = create(:employer)
      sign_in(employer)
      run_request_and_cache_response(report_as: 'new_dashboard_internship_offer_path') do
        visit new_dashboard_internship_offer_path
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
          visit user.custom_dashboard_path
        end
      end
    end

    test 'school_manager dashboard_school_users_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      create(:teacher, school: school)
      create(:main_teacher, school: school)
      create(:other, school: school)

      sign_in(school_manager)
      run_request_and_cache_response(report_as: "school_manager dashboard_school_users_path") do
        visit dashboard_school_users_path(school)
      end
    end

    test 'school_manager dashboard_school_class_rooms_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      create(:class_room, school: school)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: "school_manager dashboard_school_class_rooms_path") do
        visit dashboard_school_class_rooms_path(school)
      end
    end

    test 'school_manager edit_dashboard_school_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: "school_manager edit_dashboard_school_path") do
        visit edit_dashboard_school_path(school)
      end
    end

    test 'teacher dashboard_school_class_room_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      teacher = create(:teacher, school: school_manager.school)
      class_room = create(:class_room, school: school)
      sign_in(teacher)
      run_request_and_cache_response(report_as: "school_manager dashboard_school_class_room_path") do
        visit dashboard_school_class_room_path(school, class_room)
      end
    end

    test 'teacher dashboard_school_students_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      teacher = create(:teacher, school: school_manager.school)
      student = create(:student, school: school)
      sign_in(teacher)
      run_request_and_cache_response(report_as: "school_manager dashboard_school_students_path") do
        visit dashboard_school_students_path(school)
      end
    end
  end
end
