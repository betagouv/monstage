require 'test_helper'

module Dashboard
  class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    #
    # navigation checks
    #
    test 'GET #show as Employer displays internship_applications link' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offer_path(internship_offer)
      assert_response :success
      assert_select "a[href=?]", edit_dashboard_internship_offer_path(internship_offer),
                                 count: 1
      assert_select "a[href=?]", dashboard_internship_offer_path(internship_offer),
                                 count: 1
      assert_select "a[href=?]", dashboard_internship_offer_internship_applications_path(internship_offer),
                                 text: "0 candidatures",
                                 count: 1
    end

    test 'GET #index as Employer displays internship_applications link' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{internship_offer.id}"
      assert_select "a[href=?]", edit_dashboard_internship_offer_path(internship_offer),
                                 count: 1
      assert_template "dashboard/internship_offers/_delete_internship_offer_modal"
    end

    test 'GET #index as Operator displays internship_applications link' do
      operator = create(:user_operator)
      internship_offer = create(:internship_offer, operators: [operator.operator])
      sign_in(operator)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{internship_offer.id}"
      assert_select "a[href=?]", edit_dashboard_internship_offer_path(internship_offer),
                                 count: 0
      assert_select "a[href=?]", dashboard_internship_offer_path(internship_offer),
                                 count: 1
    end
  end
end
