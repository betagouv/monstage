require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new redirects if no type is chosen' do
    get new_user_registration_path
    assert_redirected_to users_choose_profile_path
  end

  test 'GET choose_profile' do
    get users_choose_profile_path

    assert_select "a[href=?]", "/users/sign_up?as=Student"
    assert_select "a[href=?]", "/users/sign_up?as=Employer"
    assert_select "a[href=?]", "/users/sign_up?as=SchoolManager"
  end

  test 'GET new as a SchoolManager' do
    get new_user_registration_path(as: 'SchoolManager')

    assert_response :success
    assert_select 'input', { value: 'SchoolManager', hidden: 'hidden' }
    assert_select 'label', 'Courriel professionnel'
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
                                                    type: 'Employer' }})
      assert_redirected_to root_path
    end
  end
end
