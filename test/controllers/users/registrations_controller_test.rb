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

  test "create school manager with school and weeks" do
    school = create(:school)

    post '/users', params: { user: { type: 'SchoolManager', school_id: school.id }, internship_weeks:[ weeks(:week_2019_1).id, weeks(:week_2019_2).id ]}

    assert_not_empty school.weeks
    assert_equal 2, school.weeks.count
  end
end
