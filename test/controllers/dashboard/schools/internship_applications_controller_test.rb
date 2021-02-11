# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class InternshipApplicationsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'get InternshipApplications#index as school_manager' do
        school = create(:school, :with_school_manager)
        class_room_troisieme_generale = create(:class_room, :troisieme_generale, school: school)
        class_room_troisieme_segpa = create(:class_room, :troisieme_segpa, school: school)
        student_troisieme_generale = create(:student, school: school, class_room: class_room_troisieme_generale)
        student_troisieme_segpa = create(:student, school: school, class_room: class_room_troisieme_segpa)
        application_troisieme_troisieme_generale = create(:weekly_internship_application, :approved, student: student_troisieme_generale)
        applicationt_troisieme_segpa = create(:free_date_internship_application, :approved, student: student_troisieme_segpa)
        sign_in(school.school_manager)

        get dashboard_school_internship_applications_path(school)

        assert_response :success
        assert_select ".student-application-#{application_troisieme_troisieme_generale.id}", count: 1
        assert_select ".student-application-#{applicationt_troisieme_segpa.id}", count: 0
        assert_select 'form[data-test-id="internship_agreement_preset_form"]',
                      count: 1

        school.internship_agreement_preset.update!(school_delegation_to_sign_delivered_at: 2.days.ago)
        get dashboard_school_internship_applications_path(school)

        assert_select 'form[data-test-id="internship_agreement_preset_form"]',
                      count: 0
      end

      test 'get InternshipApplications#index as main_teacher 3eme generale' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, :troisieme_generale, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        student = create(:student, school: school, class_room: class_room)
        application_troisieme = create(:weekly_internship_application, :approved, student: student)
        sign_in(main_teacher)

        get dashboard_school_internship_applications_path(school)

        assert_response :success
        assert_select ".student-application-#{application_troisieme.id}", count: 1
        assert_select 'form[data-test-id="internship_agreement_preset_form"]',
                      count: 1

        school.internship_agreement_preset.update!(school_delegation_to_sign_delivered_at: 2.days.ago)
        get dashboard_school_internship_applications_path(school)

        assert_select 'form[data-test-id="internship_agreement_preset_form"]',
                      count: 0
      end

      test 'get InternshipApplications#index as main_teacher 3eme segpa' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, :troisieme_segpa, school: school)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        student = create(:student, school: school, class_room: class_room)
        application = create(:free_date_internship_application, :approved, student: student)
        sign_in(main_teacher)

        get dashboard_school_internship_applications_path(school)

        assert_response :success
        assert_select ".student-application-#{application.id}", count: 0
        assert_select 'form[data-test-id="internship_agreement_preset_form"]',
                      count: 1

        school.internship_agreement_preset.update!(school_delegation_to_sign_delivered_at: 2.days.ago)
        get dashboard_school_internship_applications_path(school)

        assert_select 'form[data-test-id="internship_agreement_preset_form"]',
                      count: 0
      end
    end
  end
end
