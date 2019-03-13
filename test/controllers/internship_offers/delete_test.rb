require 'test_helper'


module InternshipOffers
  class DeleteTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'DELETE #destroy as visitor redirects to user_session_path' do
      internship_offer = create(:internship_offer)
      delete(internship_offer_path(internship_offer.to_param))
      assert_redirected_to user_session_path
    end

    test 'DELETE #destroy as employer not owning internship_offer redirects to user_session_path' do
      internship_offer = create(:internship_offer)
      sign_in(create(:employer))
      delete(internship_offer_path(internship_offer.to_param))
      assert_redirected_to root_path
    end

    test 'DELETE #destroy as employer owning internship_offer updates internship_offer' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      assert_changes -> { internship_offer.reload.discarded_at } do
        delete(internship_offer_path(internship_offer.to_param))
      end
    end
  end
end
