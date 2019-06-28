# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #index as Employer displays internship_applications link' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{internship_offer.id}"
    end

    test 'GET #index as Operator displays internship_applications link' do
      operator = create(:user_operator)
      another_internship_offer = create(:internship_offer)
      internship_offer_owned_by_operator = create(:internship_offer, employer: operator)
      internship_offer_delegated_to_opereator = create(:internship_offer, operators: [operator.operator])
      sign_in(operator)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{another_internship_offer.id}",
                    count: 0
      assert_select "tr.test-internship-offer-#{internship_offer_owned_by_operator.id}",
                    count: 1
      assert_select "tr.test-internship-offer-#{internship_offer_delegated_to_opereator.id}",
                    count: 1
      assert_select 'a[href=?]', edit_dashboard_internship_offer_path(internship_offer_delegated_to_opereator),
                    count: 0
      assert_select 'a[href=?]', dashboard_internship_offer_path(internship_offer_delegated_to_opereator),
                    count: 1
    end

    test 'GET #index as Operator displays api_internship_offers' do
      operator = create(:user_operator)
      internship_offer = create(:api_internship_offer, employer: operator)
      sign_in(operator)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{internship_offer.id}",
                    count: 1
    end
  end
end
