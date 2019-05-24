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

      test 'GET internship_applications#index as another student.school.school_manager responds with 200' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        school_manager = create(:school_manager, school: school)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'h1.h2.mb-3', text: student.name
        assert_select 'a[href=?]', dashboard_school_class_room_path(school, class_room)
        assert_select 'h2.h4', text: 'Aucun stage sélectionné'
      end

      test 'GET internship_applications#index render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_template 'dashboard/students/internship_applications/index'
        assert_select 'h1.h2', text: 'Mes candidatures'
        assert_select 'h2.h4', text: 'Aucun stage sélectionné'
        assert_select 'a.btn.btn-warning[href=?]', internship_offers_path
      end

      test 'GET internship_applications#index render internship_applications' do
        student = create(:student)
        internship_applications = {
          drafted: create(:internship_application, :drafted, student: student),
          submitted: create(:internship_application, :submitted, student: student),
          approved: create(:internship_application, :approved, student: student),
          rejected: create(:internship_application, :rejected, student: student),
          convention_signed: create(:internship_application, :convention_signed, student: student)
        }

        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'a.btn.btn-warning[href=?]', internship_offers_path
        internship_applications.each do |aasm_state, internship_application|
          assert_select 'a[href=?]', dashboard_students_internship_application_path(student, internship_application)
          assert_template "dashboard/students/internship_applications/states/_#{aasm_state}"
        end
        assert_select '.alert-secondary small.alert-internship-application-state',
                      text: "Candidature en attente depuis le #{I18n.localize(internship_applications[:drafted].created_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select '.alert-warning small.alert-internship-application-state',
                      text: "Candidature acceptée le #{I18n.localize(internship_applications[:approved].approved_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select '.alert-success small.alert-internship-application-state',
                      text: "Convention reçue le #{I18n.localize(internship_applications[:convention_signed].convention_signed_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select 'small.alert-internship-application-state',
                      text: "Candidature refusée le #{I18n.localize(internship_applications[:rejected].rejected_at, format: :human_mm_dd)}.",
                      count: 1
        assert_select 'small.alert-internship-application-state',
                      text: "Candidature envoyée le #{I18n.localize(internship_applications[:submitted].submitted_at, format: :human_mm_dd)}.",
                      count: 1
      end

      test 'GET internship_applications#show not connected responds with redireciton' do
        student = create(:student)
        internship_application = create(:internship_application, student: student)
        get dashboard_students_internship_application_path(student,
                                                           internship_application)
        assert_response :redirect
      end

      test 'GET internship_applications#show render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        internship_applications = create(:internship_application, student: student)

        get dashboard_students_internship_application_path(student,
                                                           internship_applications)
        assert_response :success

        assert_template 'dashboard/students/internship_applications/show'
        assert_template 'dashboard/students/_timeline'
      end

      test 'GET internship_applications#show with drafted can be submitted' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:internship_application, student: student)

        get dashboard_students_internship_application_path(student,
                                                           internship_application)
        assert_response :success
        assert_select "a.btn-warning[href=\"#{internship_offer_internship_application_path(internship_application.internship_offer, internship_application, transition: :submit!)}\"]"
        assert_select 'a.btn-warning[data-method=patch]'
      end
    end
  end
end
