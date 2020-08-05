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
            stree: '12 rue des bois',
            zipcode: '75001',
            city: 'Paris',
            description: 'Activités de découverte',
            weeks_ids: [weeks(:week_2019_1).id, weeks(:week_2019_2).id]
          }
        })
      assert_redirected_to user_session_path
    end
  end
end
