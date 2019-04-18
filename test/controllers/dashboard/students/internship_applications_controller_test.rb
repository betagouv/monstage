require 'test_helper'

module Dashboard
  module Students
    class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'index has timeline' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
      end
    end
  end
end
