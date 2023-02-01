# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'PATCH #update as visitor redirects to user_session_path' do
      internship_offer_info = create(:weekly_internship_offer_info)
      employer = internship_offer_info.employer
      organisation = create(:organisation, employer: employer)
      tutor = create(:tutor, employer_id: employer.id)
      internship_offer = create(:weekly_internship_offer, employer: employer, organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id, tutor_id: tutor.id)
      patch(dashboard_internship_offer_path(internship_offer.to_param), params: {})
      assert_redirected_to user_session_path

      patch(dashboard_stepper_internship_offer_info_path(internship_offer_info.to_param), params: {})
      assert_redirected_to user_session_path
    end

      

    test 'PATCH #update as employer owning internship_offer can publish/unpublish offer' do
      internship_offer = create(:weekly_internship_offer)
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
