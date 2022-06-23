# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Students
    class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'GET internship_applications#index not connected responds with redireciton' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_response :redirect
      end

      test 'GET internship_applications#index as another student responds with redireciton' do
        student_1 = create(:student)
        sign_in(student_1)
        get dashboard_students_internship_applications_path(create(:student))
        assert_response :redirect
      end

      test 'GET internship_applications#index as student.school.school_manager responds with 200' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        school_manager = create(:school_manager, school: school)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'title', 'Mes candidatures | Monstage'
        assert_select 'h1.h2.mb-3', text: student.name
        assert_select 'a[href=?]', dashboard_school_class_room_students_path(school, class_room)
        assert_select 'h2.h4', text: 'Aucun stage sélectionné'
      end

      test 'GET internship_applications#index as student.school.school_manager works and show convention button' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        school_manager = create(:school_manager, school: school)
        internship_application = create(:weekly_internship_application, :approved, student: student)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'a[href=?]', dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application, transition: :signed!)
      end

      test 'GET internship_applications#index as SchoolManagement works and show convention button' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        internship_application = create(:weekly_internship_application, :approved, student: student)
        sign_in(main_teacher)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'a[href=?]', dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application, transition: :signed!)
      end

      test 'GET internship_applications#index render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_template 'dashboard/students/internship_applications/index'
        assert_select 'h1.h2', text: 'Mes candidatures'
        assert_select 'h2.h4', text: 'Aucun stage sélectionné'
        assert_select 'a.fr-btn[href=?]', student.presenter.default_internship_offers_path
      end

      test 'GET internship_applications#index render internship_applications' do
        student = create(:student)
        states = %i[drafted
                    submitted
                    approved
                    rejected
                    expired
                    convention_signed
                    canceled_by_employer
                    canceled_by_student]
        internship_applications = states.each_with_object({}) do |state, accu|
          accu[state] = create(:weekly_internship_application, state, student: student)
        end

        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'a.fr-btn[href=?]',
                      student.presenter.default_internship_offers_path
        internship_applications.each do |aasm_state, internship_application|
          assert_select 'a[href=?]', dashboard_students_internship_application_path(student, internship_application)
          assert_template "dashboard/students/internship_applications/states/_#{aasm_state}"
        end
        assert_select '.alert-secondary .alert-internship-application-state',
                      text: "Candidature en attente depuis le #{I18n.localize(internship_applications[:drafted].created_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select '.alert-warning .alert-internship-application-state',
                      text: "Candidature acceptée le #{I18n.localize(internship_applications[:approved].approved_at, format: :human_mm_dd)}.",
                      count: 1
        # following test looks very much the same as the former one because
        # the view shows the same info for this particular state
        assert_select '.alert-success .alert-internship-application-state',
                      text: "Candidature acceptée le #{I18n.localize(internship_applications[:convention_signed].approved_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select '.alert-internship-application-state',
                      text: "Candidature refusée le #{I18n.localize(internship_applications[:rejected].rejected_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select '.alert-internship-application-state',
                      text: "Candidature envoyée le #{I18n.localize(internship_applications[:submitted].submitted_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select '.alert-internship-application-state',
                      text: "Candidature expirée le #{I18n.localize(internship_applications[:expired].expired_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select '.alert-internship-application-state',
                      text: "Candidature annulée le #{I18n.localize(internship_applications[:canceled_by_student].canceled_at, format: :human_mm_dd)}.",
                      count: 1
      end

      test 'GET internship_applications#show not connected responds with redireciton' do
        student = create(:student)
        internship_application = create(:weekly_internship_application, student: student)
        get dashboard_students_internship_application_path(student,
                                                           internship_application)
        assert_response :redirect
      end

      test 'GET internship_applications#show render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:weekly_internship_application, {
                                          student: student,
                                          aasm_state: :convention_signed,
                                          convention_signed_at: 1.days.ago,
                                          approved_at: 1.days.ago,
                                          submitted_at: 2.days.ago
                                        })

        get dashboard_students_internship_application_path(student,
                                                           internship_application)
        assert_response :success

        assert_template 'dashboard/students/internship_applications/show'
        assert_template 'dashboard/students/_timeline'
        assert_select '#tab-internship-application-detail .alert-internship-application-state',
                      text: "Candidature envoyée le #{I18n.localize(internship_application.submitted_at, format: :human_mm_dd)}.",
                      count: 1
      end

      test 'GET internship_applications#show with drafted can be submitted' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:weekly_internship_application, student: student)

        get dashboard_students_internship_application_path(student,
                                                           internship_application)
        assert_response :success
        assert_select "a[href=\"#{internship_offer_internship_application_path(internship_application.internship_offer, internship_application, transition: :submit!)}\"]"
        assert_select 'a[data-method=patch]'
      end
    end
  end
end
