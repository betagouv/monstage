# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class InternshipApplicationsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # update by group
      #
      test 'PATCH students as SchoolManagement change class room' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        application = create(:weekly_internship_application, :approved, student: student)
        sign_in(school.school_manager)

        get dashboard_school_internship_applications_path(school)

        assert_response :success
        assert_select ".student-application-#{application.id}"
      end
    end
  end
end
