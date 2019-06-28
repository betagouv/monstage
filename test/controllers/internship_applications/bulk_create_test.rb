# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'POST #bulk_create internship application as school_manager' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room, school: school)
      internship_offer = create(:internship_offer, school: school)

      sign_in(school.school_manager)
      valid_params = { internship_application: { internship_offer_week_id: internship_offer.internship_offer_weeks.first.id,
                                                 student_ids: [student.id] } }
      assert_difference('InternshipApplication.count', 1) do
        post(bulk_create_internship_offer_internship_applications_path(internship_offer_id: internship_offer.id), params: valid_params)
      end

      created_internship_application = InternshipApplication.last
      assert_equal "approved", created_internship_application.aasm_state
      assert_equal internship_offer.internship_offer_weeks.first.id, created_internship_application.internship_offer_week.id
      assert_equal student.id, created_internship_application.student.id
    end

  end
end
