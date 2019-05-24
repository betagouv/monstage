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
        assert_select 'select[name="internship_offer[week_ids][]"] option', 14
        assert_select 'option', text: 'Semaine 9 - du 25 février au 3 mars'
        assert_select 'option', text: 'Semaine 10 - du 4 mars au 10 mars'
        assert_select 'option', text: 'Semaine 11 - du 11 mars au 17 mars'
        assert_select 'option', text: 'Semaine 12 - du 18 mars au 24 mars'
        assert_select 'option', text: 'Semaine 13 - du 25 mars au 31 mars'
        assert_select 'option', text: 'Semaine 14 - du 1 avril au 7 avril'
        assert_select 'option', text: 'Semaine 15 - du 8 avril au 14 avril'
        assert_select 'option', text: 'Semaine 16 - du 15 avril au 21 avril'
        assert_select 'option', text: 'Semaine 17 - du 22 avril au 28 avril'
        assert_select 'option', text: 'Semaine 18 - du 29 avril au 5 mai'
        assert_select 'option', text: 'Semaine 19 - du 6 mai au 12 mai'
        assert_select 'option', text: 'Semaine 20 - du 13 mai au 19 mai'
        assert_select 'option', text: 'Semaine 21 - du 20 mai au 26 mai'
        assert_select 'option', text: 'Semaine 22 - du 27 mai au 2 juin'
      end

      travel_to(Date.new(2019, 5, 15)) do
        get new_dashboard_internship_offer_path

        assert_response :success
        assert_select 'select[name="internship_offer[week_ids][]"] option', 3
        assert_select 'option', text: 'Semaine 20 - du 13 mai au 19 mai'
        assert_select 'option', text: 'Semaine 21 - du 20 mai au 26 mai'
        assert_select 'option', text: 'Semaine 22 - du 27 mai au 2 juin'
      end
    end

    test 'GET #edit as Operator with disabled fields if applications exist' do
      operator = create(:user_operator)
      sign_in(operator)

      get new_dashboard_internship_offer_path
      assert_response :success
      assert_select '#internship_offer_operator_ids[disabled]'
    end

    test 'GET #new as visitor redirects to internship_offers' do
      get new_dashboard_internship_offer_path
      assert_redirected_to user_session_path
    end
  end
end
