require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "GET index as Student" do
    sign_in(create(:student))
    get account_path

    assert_template "accounts/_school_card"
  end

  test "GET index as SchoolManager" do
    sign_in(create(:school_manager))
    get account_path

    assert_template "accounts/_school_card"
    assert_template "accounts/_school_internship_week_card"
    assert_template "accounts/_class_room_card"
  end
end
