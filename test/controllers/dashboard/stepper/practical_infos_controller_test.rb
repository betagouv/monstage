# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class PracticalInfosControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New PracticalInfo
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_practical_info_path
      assert_redirected_to user_session_path
    end

    test 'GET #new as employer show valid form' do
      employer = create(:employer)
      sign_in(employer)
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation, employer: employer)
        internship_offer_info = create(:internship_offer_info)
        hosting_info = create(:hosting_info)

        get new_dashboard_stepper_practical_info_path(
          organisation_id: organisation.id,
          internship_offer_info_id: internship_offer_info.id,
          hosting_info_id: hosting_info.id)

        assert_response :success
        asserted_input_count = 0
      end
    end

    test 'GET #new as employer is not turbolinkable' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      get new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
      assert_select 'meta[name="turbo-visit-control"][content="reload"]'
    end

    #
    # Create PracticalInfo
    #
    test 'POST create redirects to new tutor' do
      employer = create(:employer, phone: '+330623456789')
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info, employer: employer)
      hosting_info = create(:hosting_info, employer: employer)
      
      assert_difference('InternshipOffer.count', 1) do
        assert_difference('PracticalInfo.count', 1) do
          post(
            dashboard_stepper_practical_infos_path(
              organisation_id: organisation.id,
              internship_offer_info_id: internship_offer_info.id,
              hosting_info_id: hosting_info.id),
            params: {
              practical_info: {
                street: '12 rue des bois',
                street_complement: 'Batiment 1',
                zipcode: '75001',
                city: 'Paris',
                coordinates: { latitude: 1, longitude: 1 },
                contact_phone: '+330623456789',
                daily_hours: {
                  "lundi" => ['08:00', '15:00'],
                  "mardi" => ['08:00', '13:00'],
                  "mercredi" => ['09:00', '14:00'],
                  "jeudi" => ['10:00', '15:00'],
                  "vendredi" => ['11:00', '16:00']
                }
              },
            })
        end
      end

      created_practical_info = PracticalInfo.last
      created_internship_offer = InternshipOffer.last
      assert_equal '12 rue des bois - Batiment 1', created_practical_info.street
      assert_equal '75001', created_practical_info.zipcode
      assert_equal 'Paris', created_practical_info.city
      assert_equal 1, created_practical_info.coordinates.latitude
      assert_equal 1, created_practical_info.coordinates.longitude
      assert_equal ['08:00', '15:00'], created_practical_info.daily_hours["lundi"]
      assert_equal ['08:00', '13:00'], created_practical_info.daily_hours["mardi"]
      assert_equal ['09:00', '14:00'], created_practical_info.daily_hours["mercredi"]
      assert_equal ['10:00', '15:00'], created_practical_info.daily_hours["jeudi"]
      assert_equal ['11:00', '16:00'], created_practical_info.daily_hours["vendredi"]
      
      assert_redirected_to internship_offer_path(created_internship_offer, origine: 'dashboard', stepper: true)

      # recopy organisation
      assert_equal organisation.employer_name, created_internship_offer.employer_name
      assert_equal organisation.street, created_internship_offer.organisation.street
      assert_equal organisation.zipcode, created_internship_offer.organisation.zipcode
      assert_equal organisation.city, created_internship_offer.organisation.city
      assert_equal organisation.coordinates, created_internship_offer.organisation.coordinates
      assert_equal organisation.is_public, created_internship_offer.is_public
      assert_equal organisation.group_id, created_internship_offer.group_id
      assert_equal organisation.employer_website, created_internship_offer.employer_website

      # recopy internship_offer_info
      assert_equal internship_offer_info.title, created_internship_offer.title
      # assert_equal internship_offer_info.description_rich_text.to_s, created_internship_offer.description_rich_text.to_s
      assert_equal internship_offer_info.sector, created_internship_offer.sector

      # recopy hosting_info
      assert_equal hosting_info.max_candidates, created_internship_offer.max_candidates
      assert_equal hosting_info.weeks, created_internship_offer.weeks

      # recopy practical_info
      assert_equal created_practical_info, created_internship_offer.practical_info
      assert_nil(created_internship_offer.school_id,'school_id not copied')
      assert_equal(created_practical_info.weekly_hours,
                   created_internship_offer.weekly_hours,
                   'weekly_hours not copied')
      assert_equal(created_practical_info.daily_hours,
                   created_internship_offer.daily_hours,
                   'daily_hours not copied')
      assert_equal created_practical_info.street, created_internship_offer.street
      assert_equal created_practical_info.zipcode, created_internship_offer.zipcode
      assert_equal created_practical_info.city, created_internship_offer.city
      assert_equal created_practical_info.coordinates, created_internship_offer.coordinates
    end

    test 'POST create when already created redirects to internship offer' do
      employer = create(:employer, phone: '+330623456789')
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info, employer: employer)
      hosting_info = create(:hosting_info, employer: employer)
      
      # first time
      assert_enqueued_jobs 1, only: DraftedInternshipOfferJob do
        assert_difference('InternshipOffer.count', 1) do
          assert_difference('PracticalInfo.count', 1) do
            post(
              dashboard_stepper_practical_infos_path(
                organisation_id: organisation.id,
                internship_offer_info_id: internship_offer_info.id,
                hosting_info_id: hosting_info.id),
              params: {
                practical_info: {
                  street: '12 rue des bois',
                  street_complement: 'Batiment 1',
                  zipcode: '75001',
                  city: 'Paris',
                  coordinates: { latitude: 1, longitude: 1 },
                  contact_phone: '+330623456789',
                  daily_hours: {
                    "lundi" => ['08:00', '15:00'],
                    "mardi" => ['08:00', '13:00'],
                    "mercredi" => ['09:00', '14:00'],
                    "jeudi" => ['10:00', '15:00'],
                    "vendredi" => ['11:00', '16:00']
                  }
                },
              })
          end
        end
      end

      # second time
      assert_no_difference('InternshipOffer.count') do
        post(
          dashboard_stepper_practical_infos_path(
            organisation_id: organisation.id,
            internship_offer_info_id: internship_offer_info.id,
            hosting_info_id: hosting_info.id),
          params: {
            practical_info: {
              street: '12 rue des bois',
              street_complement: 'Batiment 1',
              zipcode: '75001',
              city: 'Paris',
              coordinates: { latitude: 1, longitude: 1 },
              contact_phone: '+330623456789',
              daily_hours: {
                "lundi" => ['08:00', '15:00'],
                "mardi" => ['08:00', '13:00'],
                "mercredi" => ['09:00', '14:00'],
                "jeudi" => ['10:00', '15:00'],
                "vendredi" => ['11:00', '16:00']
              }
            },
          })
      end     
    end

    test 'POST #create as employer with missing params' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info)
      hosting_info = create(:hosting_info)

      post(
        dashboard_stepper_practical_infos_path(organisation_id: organisation.id,
                                      internship_offer_info_id: internship_offer_info.id,
                                      hosting_info_id: hosting_info.id),
        params: {
          practical_info: {
            street: '12 rue des bois'
          }
        }
      )
      assert_response :bad_request
    end
  end
end