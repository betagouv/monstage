require "test_helper"

class UrlShrinkersControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to root when url is not found" do
    get "/link_shrinkers/unknown_token"
    assert_redirected_to root_url
  end

  test "should redirect to original url when url is found" do
    url_shrinker = create(:url_shrinker)
    assert url_shrinker.click_count == 0
    get open_url_shrinker_url(id: url_shrinker.url_token)
    assert_equal 302, response.status
    assert url_shrinker.reload.click_count == 1
    assert_response :redirect
    follow_redirect!
    assert_select("a", text: "Mentions légales")
  end
end