require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new responds with success' do
    get new_user_registration_path
    assert_response :success
  end

  test 'POST create responds with success' do
    assert_difference("SchoolManager.count") do
      post user_registration_path(params: { user: { email: 'test@ac-edu.fr',
                                                     password: 'okokok',
                                                     password_confirmation: 'okokok',
                                                     type: 'SchoolManager' }})
      assert_redirected_to account_path
    end
  end
end
