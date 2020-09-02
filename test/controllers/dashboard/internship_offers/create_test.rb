# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'POST #create as visitor redirects to internship_offers' do
      post dashboard_internship_offers_path(params: {})
      assert_redirected_to user_session_path
    end

    test 'POST #create/InternshipOffers::WeeklyFramed as employer creates the post' do
      sign_in(create(:employer))
      weeks = [weeks(:week_2019_1)]
      internship_offer_info = create(:weekly_internship_offer_info)
      organisation = create(:organisation)
      params = {
        tutor_name: 'Jean Paul',
        tutor_email: 'jp@gmail.com',
        tutor_phone: '0102030405',
        internship_offer_info_id: internship_offer_info.id,
        organisation_id: organisation.id
      }

      assert_difference('InternshipOffer.count', 1) do
        post(dashboard_internship_offers_path, params: { internship_offer: params })
      end
      created_internship_offer = InternshipOffer.last
      assert_equal InternshipOffers::WeeklyFramed.name, created_internship_offer.type
      assert_equal internship_offer_info.weeks.map(&:id), created_internship_offer.week_ids
      assert_equal weeks.size, created_internship_offer.internship_offer_weeks_count
      assert_equal internship_offer_info.max_candidates, created_internship_offer.max_candidates
      assert_redirected_to internship_offer_path(created_internship_offer)
    end

    test 'POST #create/InternshipOffers::FreeDate as employer creates the post' do
      employer = create(:employer)
      sign_in(employer)
      school = create(:school)
      weeks = [weeks(:week_2019_1)]
      internship_offer_info = create(:weekly_internship_offer_info, 
                                      school: school,
                                      type: InternshipOfferInfos::FreeDateInfo.name)
      organisation = create(:organisation)

      params = {
        tutor_name: 'Jean Paul',
        tutor_email: 'jp@gmail.com',
        tutor_phone: '0102030405',
        internship_offer_info_id: internship_offer_info.id,
        organisation_id: organisation.id
      }

      assert_difference('InternshipOffer.count', 1) do
        post(dashboard_internship_offers_path, params: { internship_offer: params })
      end
      created_internship_offer = InternshipOffer.last
      assert_equal InternshipOffers::FreeDate.name, created_internship_offer.type
      assert_equal employer, created_internship_offer.employer
      assert_equal school, created_internship_offer.school
      assert_redirected_to internship_offer_path(created_internship_offer)
    end

    test 'POST #create as employer with missing params' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: { internship_offer: {} })
      assert_response :bad_request
    end
  end
end
