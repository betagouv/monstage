require 'test_helper'

class InternshipOfferRemoteControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get internship_offer_remote_index_url
    assert_response :success
  end
end
