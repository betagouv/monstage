require 'test_helper'

module Dashboard
  module Students
    class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'index responds with 200' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
      end

      test 'index render navbar, timeline' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_template 'dashboard/students/_navbar'
        assert_template 'dashboard/students/_timeline'
      end
    end
  end
end
