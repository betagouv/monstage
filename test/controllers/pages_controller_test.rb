require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  test "home" do
    get root_path
    assert_response :success
    assert_template 'pages/home'
  end
end
