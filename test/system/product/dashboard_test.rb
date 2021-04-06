# frozen_string_literal: true

require 'application_system_test_case'

module Product
  class DashboardTest < ApplicationSystemTestCase
    test 'dashboard_internship_offers_path' do
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

    test 'edit_dashboard_internship_offer_path' do
      stage_dev = create(:weekly_internship_offer)
      sign_in(stage_dev.employer)
      run_request_and_cache_response(report_as: 'edit_dashboard_internship_offer_path') do
        visit edit_dashboard_internship_offer_path(id: stage_dev.to_param)
      end
    end


    test 'new_dashboard_internship_offer_path(duplicate_id)' do
      stage_dev = create(:weekly_internship_offer)
      sign_in(stage_dev.employer)
      run_request_and_cache_response(report_as: 'new_dashboard_internship_offer_path') do
        visit new_dashboard_internship_offer_path(duplicate_id: stage_dev.id)
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

    test 'index as school manager without presets' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, :troisieme_generale, school: school)
      student = create(:student, school: school, class_room: class_room)

      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student)
      sign_in(school.school_manager)
      run_request_and_cache_response(report_as: 'school_manager_dashboard_school_internship_applications_path_without_presets') do
        visit dashboard_school_internship_applications_path(school)
      end
    end

    test 'index as school manager with presets' do
      school = create(:school, :with_agreement_presets, :with_school_manager)
      class_room = create(:class_room, :troisieme_generale, school: school)
      student = create(:student, school: school, class_room: class_room)

      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student)
      sign_in(school.school_manager)

      run_request_and_cache_response(report_as: 'school_manager_dashboard_school_internship_applications_path_with_presets') do
        visit dashboard_school_internship_applications_path(school)
      end
    end


    test 'index as school_manager see progress' do
      school = create(:school, :with_agreement_presets, :with_school_manager)
      class_room = create(:class_room, :troisieme_generale, school: school)

      internship_application_1 = create(:weekly_internship_application,
                                               :approved,
                                                student: create(:student, school: school, class_room: class_room))
      internship_application_2 = create(:weekly_internship_application,
                                               :approved,
                                                student: create(:student, school: school, class_room: class_room))
      internship_application_3 = create(:weekly_internship_application,
                                               :approved,
                                                student: create(:student, school: school, class_room: class_room))
      internship_application_4 = create(:weekly_internship_application,
                                               :approved,
                                                student: create(:student, school: school, class_room: class_room))

      create(:internship_agreement, internship_application: internship_application_2,
                                    employer_accept_terms: true,
                                    school_manager_accept_terms: false)
      create(:internship_agreement, internship_application: internship_application_3,
                                    employer_accept_terms: false,
                                    school_manager_accept_terms: true)
      create(:internship_agreement, internship_application: internship_application_4,
                                    employer_accept_terms: true,
                                    school_manager_accept_terms: true)
      sign_in(school.school_manager)
      run_request_and_cache_response(report_as: 'school_manager_dashboard_school_internship_applications_path_with_steps') do
        visit dashboard_school_internship_applications_path(school)
      end
    end

    test 'employer dashboard_internship_applications_path' do
      internship_application = create(:weekly_internship_application, :approved)
      sign_in(internship_application.internship_offer.employer)
      run_request_and_cache_response(report_as: 'dashboard_internship_applications_path') do
        visit dashboard_internship_applications_path
      end
    end


    test 'school_manager dashboard_school_users_path' do
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

    test 'school_manager dashboard_school_class_rooms_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      create(:class_room, school: school)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'school_manager dashboard_school_class_rooms_path') do
        visit dashboard_school_class_rooms_path(school)
      end
    end

    test 'school_manager edit_dashboard_school_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      sign_in(school_manager)
      run_request_and_cache_response(report_as: 'school_manager edit_dashboard_school_path') do
        visit edit_dashboard_school_path(school)
      end
    end

    test 'teacher dashboard_school_class_room_path' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      teacher = create(:teacher, school: school_manager.school)
      class_room = create(:class_room, school: school)
      sign_in(teacher)
      run_request_and_cache_response(report_as: 'school_manager dashboard_school_class_room_path') do
        visit dashboard_school_class_room_path(school, class_room)
      end
    end

    test 'school_manager new_dashboard_agreement_path' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer
                                      )
      sign_in(school.school_manager)
      run_request_and_cache_response(report_as: 'school_manager new_dashboard_ageement_path') do
        visit new_dashboard_internship_agreement_path(internship_application_id: internship_application.id)
      end
    end

    test 'employer new_dashboard_agreement_path' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer)
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)
      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer
                                      )
      sign_in(employer)
      run_request_and_cache_response(report_as: 'employer new_dashboard_ageement_path') do
        visit new_dashboard_internship_agreement_path(internship_application_id: internship_application.id)
      end
    end

    test 'school_manager edit_dashboard_agreement_path' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :created_by_system)
      sign_in(internship_agreement.internship_application.student.school_manager)
      run_request_and_cache_response(report_as: 'school_manager edit_dashboard_ageement_path') do
        visit edit_dashboard_internship_agreement_path(id: internship_agreement.id)
      end
    end

    test 'employer edit_dashboard_agreement_path' do
      internship_agreement = create(:troisieme_generale_internship_agreement, :created_by_system)
      sign_in(internship_agreement.internship_application.internship_offer.employer)
      run_request_and_cache_response(report_as: 'employer edit_dashboard_ageement_path') do
        visit edit_dashboard_internship_agreement_path(id: internship_agreement.id)
      end
    end
  end
end
