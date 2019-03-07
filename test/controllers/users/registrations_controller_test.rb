require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new responds with success' do
    get new_user_registration_path
    assert_response :success
  end
end
