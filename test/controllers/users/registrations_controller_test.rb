require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new responds with success' do
    get new_user_registration_path
    assert_response :success
  end

  test 'POST create School Manager responds with success' do
    assert_difference("SchoolManager.count") do
      post user_registration_path(params: { user: { email: 'test@ac-edu.fr',
                                                     password: 'okokok',
                                                     password_confirmation: 'okokok',
                                                     first_name: 'Chef',
                                                     last_name: 'Etablissement',
                                                     type: 'SchoolManager' }})
      assert_redirected_to account_path
    end
  end

  test 'POST Create Student' do
    assert_difference("Student.count") do
      post user_registration_path(params: { user: { email: 'fatou@snapchat.com',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    first_name: 'Fatou',
                                                    last_name: 'D',
                                                    type: 'Student' }})
      assert_redirected_to root_path
    end
  end

  test 'POST Create Employer' do
    assert_difference("Employer.count") do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    first_name: 'Madame',
                                                    last_name: 'Accor',
                                                    type: 'Employer' }})
      assert_redirected_to root_path
    end
  end
end
