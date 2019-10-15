# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'PATCH #update as visitor redirects to user_session_path' do
      internship_offer = create(:internship_offer)
      patch(dashboard_internship_offer_path(internship_offer.to_param), params: {})
      assert_redirected_to user_session_path
    end

    test 'PATCH #update as employer not owning internship_offer redirects to user_session_path' do
      internship_offer = create(:internship_offer)
      sign_in(create(:employer))
      patch(dashboard_internship_offer_path(internship_offer.to_param), params: { internship_offer: { title: '' } })
      assert_redirected_to root_path
    end

    test 'PATCH #update as employer owning internship_offer updates internship_offer' do
      internship_offer = create(:internship_offer)
      new_title = 'new title'

      sign_in(internship_offer.employer)
      patch(dashboard_internship_offer_path(internship_offer.to_param),
            params: { internship_offer: {
              title: new_title,
              week_ids: [weeks(:week_2019_1).id],
              is_public: false,
              group: Group::PRIVATE.first
            } })
      assert_redirected_to(dashboard_internship_offer_path(internship_offer),
                           'redirection should point to updated offer')
      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
    end

    test 'PATCH #update as employer owning internship_offer can publish/unpublish offer' do
      internship_offer = create(:internship_offer)
      published_at = 2.days.ago.utc
      sign_in(internship_offer.employer)
      assert_changes -> { internship_offer.reload.published_at.to_i },
                     from: internship_offer.published_at.to_i,
                     to: published_at.to_i do
        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: { published_at: published_at } })
      end
    end
  end
end
