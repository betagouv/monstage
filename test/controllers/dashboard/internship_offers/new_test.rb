# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class NewTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as employer show valid form' do
      sign_in(create(:employer))
      travel_to(Date.new(2019, 3, 1)) do
        get new_dashboard_internship_offer_path

        assert_response :success
        available_weeks = Week.selectable_from_now_until_end_of_period
        asserted_input_count = 0
        available_weeks.each do |week|
          assert_select "input[id=internship_offer_week_ids_#{week.id}]"
          asserted_input_count += 1
        end
        assert asserted_input_count > 0
      end
    end

    test 'GET #edit as Operator with disabled fields if applications exist' do
      user_operator = create(:user_operator)
      sign_in(user_operator)
      operator = create(:operator)
      internship_offer = create(:internship_offer, employer: user_operator)

      get new_dashboard_internship_offer_path
      assert_response :success
      assert_select "#internship_offer_operator_ids_#{operator.id}[disabled]"
    end

    test 'GET #new as visitor redirects to internship_offers' do
      get new_dashboard_internship_offer_path
      assert_redirected_to user_session_path
    end
  end
end
