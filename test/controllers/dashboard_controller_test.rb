require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "GET index as God" do
    sign_in(create(:god))
    get dashboard_path

    assert_select "a[href=?]", schools_path
  end
end
