require 'test_helper'


module InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #edit as visitor redirects to internship_offers' do
      get edit_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to root_path
    end

    test 'GET #edit as employer' do
      sign_in(create(:employer)) do
        get edit_internship_offer_path(create(:internship_offer).to_param)
        assert_response :success
      end
    end
  end
end
