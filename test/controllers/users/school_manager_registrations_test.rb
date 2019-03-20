require 'test_helper'

class SchoolManagerRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as a SchoolManager' do
    get new_user_registration_path(as: 'SchoolManager')

    assert_response :success
    assert_select 'input', { value: 'SchoolManager', hidden: 'hidden' }
    assert_select 'label', /Mon courriel professionnel/
  end

  test 'POST create School Manager responds with success' do
    assert_difference("Users::SchoolManager.count") do
      post user_registration_path(params: { user: { email: 'test@ac-edu.fr',
                                                     password: 'okokok',
                                                     password_confirmation: 'okokok',
                                                     first_name: 'Chef',
                                                     last_name: 'Etablissement',
                                                     type: 'Users::SchoolManager' }})
      assert_redirected_to root_path
    end
  end
end
