require 'test_helper'


module InternshipOffers
  class EditTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #edit as visitor redirects to user_session_path' do
      get edit_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to user_session_path
    end

    test 'GET #edit as employer not owning internship_offer redirects to user_session_path' do
      sign_in(create(:employer))
      get edit_internship_offer_path(create(:internship_offer).to_param)
      assert_redirected_to root_path
    end

    test 'GET #edit as employer owning internship_offer renders success' do
      employer = create(:employer)
      sign_in(employer)
      get edit_internship_offer_path(create(:internship_offer, employer: employer).to_param)
      assert_response :success
    end
  end
end
