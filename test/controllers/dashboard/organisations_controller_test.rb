# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class OrganisationsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New Organisation
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_organisations_path
      assert_redirected_to user_session_path
    end
  end
end
