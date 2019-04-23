require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test "POST #create internship application" do
      internship_offer = create(:internship_offer)
      student = create(:student)
      sign_in(student)
      valid_params = { internship_application: { internship_offer_week_id: internship_offer.internship_offer_weeks.first.id,
                                                 motivation: 'Je suis trop motivé wesh',
                                                 user_id: student.id
                                               }}
      assert_difference('InternshipApplication.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(internship_offer, InternshipApplication.last)
      end

      created_internship_application = InternshipApplication.last
      assert_equal internship_offer.internship_offer_weeks.first.id, created_internship_application.internship_offer_week.id
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
      assert_equal student.id, created_internship_application.student.id
    end

    test "POST #create internship application failed" do
      internship_offer = create(:internship_offer)
      student = create(:student)
      sign_in(student)
      valid_internship_application_params = { internship_offer_week_id: internship_offer.internship_offer_weeks.first.id,
                                                 motivation: 'Je suis trop motivé wesh',
                                                 user_id: student.id
                                               }

      assert_no_difference('InternshipApplication.count') do
        post(internship_offer_internship_applications_path(internship_offer),
             params: { internship_application: valid_internship_application_params.except(:motivation)})
      end
      assert_response :bad_request

      assert_no_difference('InternshipApplication.count') do
        post(internship_offer_internship_applications_path(internship_offer),
             params: { internship_application: valid_internship_application_params.except(:internship_offer_week_id)})
      end
      assert_response :bad_request

      assert_no_difference('InternshipApplication.count') do
        post(internship_offer_internship_applications_path(internship_offer),
             params: { internship_application: valid_internship_application_params.except(:user_id)})
      end
      assert_response :bad_request
    end
  end
end
