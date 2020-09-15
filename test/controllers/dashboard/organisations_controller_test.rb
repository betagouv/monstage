# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class OrganisationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New Organisation
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_organisation_path
      assert_redirected_to user_session_path
    end

    test 'GET #new as Employer with duplicate_id with old offer' do
      internship_offer = create(:weekly_internship_offer,
                                employer_name: 'Apple',
                                street: '12 rue des bois',
                                city: 'Paris',
                                zipcode: '75001',
                                employer_website: 'https://www.site.com',
                                description: 'ma description',
                                is_public: 'true',
                              )
      sign_in(internship_offer.employer)
      get new_dashboard_organisation_path(duplicate_id: internship_offer.id)
      assert_response :success
      assert_select 'input[name="organisation[name]"][value="Apple"]'
      assert_select 'input[name="organisation[is_public]"][value="true"]'
      assert_select 'input[name="organisation[website]"][value="https://www.site.com"]'
    end

    #
    # Create Organisation
    #
    test 'POST create redirects to new internship offer info' do
      sign_in(create(:employer))

      post(
        dashboard_organisations_path,
        params: {
          organisation: {
            name: 'BigCorp',
            street: '12 rue des bois',
            zipcode: '75001',
            city: 'Paris',
            coordinates: { latitude: 1, longitude: 1 },
            description_rich_text: '<div><b>Activités de découverte</b></div>',
            is_public: 'true',
            website: 'www.website.com'
          }
        })
      created_organisation = Organisation.last
      assert_equal 'BigCorp', created_organisation.name
      assert_equal '12 rue des bois', created_organisation.street
      assert_equal '75001', created_organisation.zipcode
      assert_equal 'Paris', created_organisation.city
      assert_equal 'Activités de découverte', created_organisation.description
      assert_equal 'www.website.com', created_organisation.website
      assert_equal true, created_organisation.is_public
      assert_redirected_to new_dashboard_internship_offer_info_path(organisation_id: created_organisation.id)
    end

    
    test 'POST create render new when missing params' do
      sign_in(create(:employer))

      post(
        dashboard_organisations_path,
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
