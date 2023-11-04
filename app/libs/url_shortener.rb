class UrlShortener
  def self.short_url(url, user_id)
    # client = Bitly::API::Client.new(token: ENV['BITLY_TOKEN'])

    # bitlink = client.shorten(long_url: url)
    # bitlink.link

    url_shrinker = UrlShrinker.add(url: url, user_id: user_id)
    Rails.application
         .routes
         .url_helpers
         .link_shrinkers_url( url_token: url_shrinker.url_token, host: ENV.fetch('HOST'))
  end
end
