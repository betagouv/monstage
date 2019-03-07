require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new responds with success' do
    get new_user_registration_path
    assert_response :success
  end

  test 'GET #new render list of schools' do
    get new_user_registration_path
    create(:school)
    assert_select 'select[name="user[school_id]"] option', School.count
  end
end
