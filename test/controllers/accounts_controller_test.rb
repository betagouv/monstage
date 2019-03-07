require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "GET #edit render list of schools" do
    sign_in(create(:school_manager))
    create(:school)

    get account_path

    assert_select 'select[name="user[school_id]"] option', School.count + 1
  end

  test "create school manager with school and weeks" do
    sign_in(create(:school_manager))

    school = create(:school)

    patch account_path, params: { user: { type: 'SchoolManager', school_id: school.id }, internship_weeks:[ weeks(:week_2019_1).id, weeks(:week_2019_2).id ]}

    assert_not_empty school.weeks
    assert_equal 2, school.weeks.count
  end
end
