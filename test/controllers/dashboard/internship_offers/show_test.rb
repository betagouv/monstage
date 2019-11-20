# frozen_string_literal: true

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
      get internship_offer_path(internship_offer)
      assert_response :success
      assert_select 'a[href=?]', edit_dashboard_internship_offer_path(internship_offer),
                    count: 1

      assert_select 'a[href=?]', internship_offer_path(internship_offer),
                    count: 1
      assert_select 'a[href=?]', dashboard_internship_offer_internship_applications_path(internship_offer),
                    text: '0 candidatures',
                    count: 1
    end
  end
end
