# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'success as employer' do
      internship_application = create(:weekly_internship_application)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_applications_path
      assert_response :success
    end

    test 'fails as operator' do
      operator = create(:operator)
      user_operator = create(:user_operator, operator: operator)
      internship_offer = create(:weekly_internship_offer, employer: user_operator)
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      sign_in(user_operator)
      get dashboard_internship_applications_path
      assert_redirected_to root_path
    end
  end
end
