require "test_helper"

class UrlShrinkerTest < ActiveSupport::TestCase
  test "#short_url" do
    target_url = "https://www.google.com"
    user = create(:employer)
    short_url = UrlShrinker.short_url(url: target_url, user_id: user.id)
    assert_equal "http://example.com/c/#{UrlShrinker.last.url_token}/o", short_url
  end
end
