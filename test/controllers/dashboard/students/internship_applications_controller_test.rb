require 'test_helper'

module Dashboard
  module Students
    class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'GET internship_applications#index not connected with 400' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_response :redirect
      end

      test 'GET internship_applications#index as another student responds with 400' do
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
      end

      test 'GET internship_applications#show responds with 200' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:internship_application, student: student)
        get dashboard_students_internship_application_path(student,
                                                           internship_application)
        assert_response :success
      end

      test 'GET internship_applications#show render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        internship_applications = create(:internship_application, student: student)

        get dashboard_students_internship_application_path(student,
                                                           internship_applications)
        assert_template 'dashboard/students/internship_applications/show'
        assert_template 'dashboard/students/_navbar'
        assert_template 'dashboard/students/_timeline'
      end
    end
  end
end
