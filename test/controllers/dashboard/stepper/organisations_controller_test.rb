# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class OrganisationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New Organisation
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_organisation_path
      assert_redirected_to user_session_path
    end

    #
    # Create Organisation
    #
    test 'POST create redirects to new internship offer info' do
      employer = create(:employer)
      group  = create(:group, is_public: true)
      sign_in(employer)

      assert_changes "Organisation.count", 1 do
        post(
          dashboard_stepper_organisations_path,
          params: {
            organisation: {
              employer_name: 'BigCorp',
              street: '12 rue des bois',
              zipcode: '75001',
              city: 'Paris',
              coordinates: { latitude: 1, longitude: 1 },
              employer_description_rich_text: '<div><b>Activités de découverte</b></div>',
              is_public: group.is_public,
              group_id: group.id,
              employer_website: 'www.website.com'
            }
          })
      end

      created_organisation = Organisation.last
      assert_equal 'BigCorp', created_organisation.employer_name
      assert_equal '12 rue des bois', created_organisation.street
      assert_equal '75001', created_organisation.zipcode
      assert_equal 'Paris', created_organisation.city
      assert_equal 'Activités de découverte', created_organisation.employer_description_rich_text.to_plain_text.to_s
      assert_equal 'www.website.com', created_organisation.employer_website
      assert_equal employer.id, created_organisation.employer_id
      assert_equal true, created_organisation.is_public

      assert_redirected_to new_dashboard_stepper_internship_offer_info_path(organisation_id: created_organisation.id)
    end


    test 'POST create render new when missing params' do
      sign_in(create(:employer))

      post(
        dashboard_stepper_organisations_path,
        params: {
          organisation: {
            street: '12 rue des bois',
            zipcode: '75001',
            city: 'Paris',
            coordinates: { latitude: 1, longitude: 1 },
            description_tich_text: '<p>Activités de découverte</p>',
            is_public: 'true',
            website: 'www.website.com'
          }
        })
      assert_response :bad_request
    end
  end
end
