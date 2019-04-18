require 'test_helper'

module Dashboard
  module Students
    class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'GET internship_applications#index responds with 200' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
      end

      test 'GET internship_applications#index render navbar, timeline' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_template 'dashboard/students/internship_applications/index'
      end

      test 'GET internship_applications#show responds with 200' do
        student = create(:student)
        internship_applications = create(:internship_application, student: student)
        get dashboard_students_internship_application_path(student,
                                                           internship_applications)
        assert_response :success
      end

      test 'GET internship_applications#show render navbar, timeline' do
        student = create(:student)
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
