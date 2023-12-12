# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class InternshipOfferInfosControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New InternshipOfferInfo
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_internship_offer_info_path
      assert_redirected_to user_session_path
    end

    test 'GET #new as employer show valid form' do
      employer = create(:employer)
      sign_in(employer)
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation, employer: employer)
        get new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)

        assert_response :success
        asserted_input_count = 0
      end
    end

    #
    # Create InternshipOfferInfo
    #
    test 'POST create redirects to new hosting info' do
      employer = create(:employer)
      sign_in(employer)
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]
      organisation = create(:organisation, employer: employer)
      assert_difference('InternshipOfferInfo.count') do
        post(
          dashboard_stepper_internship_offer_infos_path(organisation_id: organisation.id),
          params: {
            internship_offer_info: {
              sector_id: sector.id,
              title: 'PDG stagiaire',
              description_rich_text: '<div><b>Activités de découverte</b></div>'
            },
          })
      end
      created_internship_offer_info = InternshipOfferInfo.last
      assert_equal 'PDG stagiaire', created_internship_offer_info.title
      assert_equal sector.id, created_internship_offer_info.sector_id
      assert_equal 'Activités de découverte', created_internship_offer_info.description_rich_text.to_plain_text
      assert_redirected_to new_dashboard_stepper_hosting_info_path(
        organisation_id: organisation.id,
        internship_offer_info_id: created_internship_offer_info.id,
      )
    end

    test 'when statistician POST create redirects to new hosting info' do
      statistician = create(:statistician)
      sign_in(statistician)
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]
      organisation = create(:organisation, employer: statistician)
      assert_difference('InternshipOfferInfo.count') do
        post(
          dashboard_stepper_internship_offer_infos_path(organisation_id: organisation.id),
          params: {
            internship_offer_info: {
              sector_id: sector.id,
              title: 'PDG stagiaire',
              description_rich_text: '<div><b>Activités de découverte</b></div>',
            },
          })
      end
      created_internship_offer_info = InternshipOfferInfo.last
      assert_equal 'PDG stagiaire', created_internship_offer_info.title
      assert_equal sector.id, created_internship_offer_info.sector_id
      assert_equal 'Activités de découverte', created_internship_offer_info.description_rich_text.to_plain_text
      assert_redirected_to new_dashboard_stepper_hosting_info_path(
        organisation_id: organisation.id,
        internship_offer_info_id: created_internship_offer_info.id,
      )
    end


    test 'POST create render new when missing params, prefill form' do
      employer = create(:employer)
      sign_in(employer)
      sector = create(:sector)
      organisation = create(:organisation, employer: employer)
      post(
        dashboard_stepper_internship_offer_infos_path(organisation_id: organisation.id),
        params: {
          internship_offer_info: { # title is missing
            sector_id: sector.id,
            description_rich_text: '<div><b>Activités de découverte</b></div>'
          }
        })
        assert_response :bad_request
    end


    test 'GET Edit' do
      title = 'ok'
      new_title = 'ko'
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info,
                                     employer: employer,
                                     title: title)
      sign_in(employer)
      assert_changes -> { internship_offer_info.reload.title },
                    from: title,
                    to: new_title do
        patch(
          dashboard_stepper_internship_offer_info_path(id: internship_offer_info.id, organisation_id: organisation.id),
          params: {
            internship_offer_info: internship_offer_info.attributes.merge({
              title: new_title,
            })
          }
        )
        assert_redirected_to new_dashboard_stepper_hosting_info_path(
          organisation_id: organisation.id,
          internship_offer_info_id: internship_offer_info.id,
        )
      end
    end
  end
end
