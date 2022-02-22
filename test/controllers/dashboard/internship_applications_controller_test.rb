# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'success as employer' do
      employer = create(:employer)

      internship_application_troisieme_generale = create(
        :weekly_internship_application,
        :approved,
        internship_offer: create(:weekly_internship_offer, employer: employer)
      )
      internship_application_troisieme_segpa = create(
        :free_date_internship_application,
        :approved,
        internship_offer: create(:free_date_internship_offer, employer: employer)
      )
      sign_in(employer)
      get dashboard_internship_applications_path
      assert_response :success
      assert_select ".student-application-#{internship_application_troisieme_generale.id}", count: 1
      assert_select ".student-application-#{internship_application_troisieme_segpa.id}", count: 0

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
