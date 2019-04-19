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
        student = create(:student, school: school)
        school_manager = create(:school_manager, school: school)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
      end

      test 'GET internship_applications#index render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_template 'dashboard/students/internship_applications/index'
        assert_select "h1.h2", text: "Mes candidatures"
        assert_select "h2.h3", text: "Aucun stage séléctionné"
        assert_select "a.btn.btn-primary[href=?]", internship_offers_path
      end

      test 'GET internship_applications#index render internship_applications' do
        student = create(:student)
        internship_application_1 = create(:internship_application, student: student)
        internship_application_2 = create(:internship_application, student: student)

        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select "a.btn.btn-link[href=?]", internship_offers_path
        assert_select "a[href=?]", dashboard_students_internship_application_path(student, internship_application_1)
        assert_select "a[href=?]", dashboard_students_internship_application_path(student, internship_application_2)
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
        assert_template 'dashboard/students/_navbar'
        assert_template 'dashboard/students/_timeline'
      end
    end
  end
end
