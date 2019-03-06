require 'test_helper'


module InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include SessionManagerTestHelper

    test 'GET #edit as visitor redirects to internship_offers' do
      get edit_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to internship_offers_path
    end

    test 'GET #edit as employer' do
      sign_in(as: MockUser::Employer) do
        get edit_internship_offer_path(create(:internship_offer).to_param)
        assert_response :success
      end
    end
  end
end
