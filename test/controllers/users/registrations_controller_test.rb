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
end
