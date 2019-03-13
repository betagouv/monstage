require 'test_helper'


module InternshipOffers
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'PATCH #update as visitor redirects to user_session_path' do
      internship_offer = create(:internship_offer)
      patch(internship_offer_path(internship_offer.to_param), params: {})
      assert_redirected_to user_session_path
    end

    test 'PATCH #update as employer not owning internship_offer redirects to user_session_path' do
      internship_offer = create(:internship_offer)
      sign_in(create(:employer))
      patch(internship_offer_path(internship_offer.to_param), params: {})
      assert_redirected_to root_path
    end

    test 'PATCH #update as employer owning internship_offer updates internship_offer' do
      internship_offer = create(:internship_offer)
      new_title = 'new title'

      sign_in(internship_offer.employer)
      patch(internship_offer_path(internship_offer.to_param),
            params: { internship_offer: {
                        title: new_title,
                        week_ids: [weeks(:week_2019_1).id],
                        is_public: false,
                        can_be_applied_for: false
                      }
                    })
      assert_redirected_to(internship_offer,
                         'redirection should point to updated offer')
      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
    end
  end
end
