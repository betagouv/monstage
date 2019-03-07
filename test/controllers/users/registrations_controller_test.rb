require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    get new_user_registration_path
  end

  test "GET new responds with success" do
    assert_response :success
  end

  test "GET #new render list of schools" do
    create(:school)
    assert_select 'select[name="user[school_id]"] option', School.count
  end
end
