# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class InternshipOfferInfosControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New InternshipOfferInfo
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_internship_offer_info_path
      assert_redirected_to user_session_path
    end

    #
    # Create InternshipOfferInfo
    #
    test 'POST create redirects to new mentor' do
      sign_in(create(:employer))
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]

      post(
        dashboard_internship_offer_infos_path,
        params: {
          internship_offer_info: {
            sector_id: sector.id,
            title: 'PDG stagiaire',
            type: 'InternshipOfferInfos::FreeDate',
            description_rich_text: '<div><b>Activités de découverte</b></div>',
            'week_ids' => weeks.map(&:id),
            organisation_id: 1
          }
        })
      created_internship_offer_info = InternshipOfferInfo.last
      assert_equal 'PDG stagiaire', created_internship_offer_info.title
      assert_equal sector.id, created_internship_offer_info.sector_id
      assert_equal 'InternshipOfferInfos::FreeDate', created_internship_offer_info.type
      assert_equal 'Activités de découverte', created_internship_offer_info.description
      # assert_equal weeks.map(&:id), created_internship_offer_info.week_ids
      assert_redirected_to new_dashboard_mentor_path(
        organisation_id: 1,
        internship_offer_info_id: created_internship_offer_info.id,
      )
    end

    
    test 'POST create render new when missing params' do
      sign_in(create(:employer))
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]

      post(
        dashboard_internship_offer_infos_path,
        params: {
          internship_offer_info: {
            sector_id: sector.id,
            type: 'InternshipOfferInfos::FreeDate',
            description_rich_text: '<div><b>Activités de découverte</b></div>',
            'week_ids' => weeks.map(&:id),
            organisation_id: 1
          }
        })
        assert_response :bad_request
    end
  end
end
