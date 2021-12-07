class UrlShortener
  def self.short_url(url)
    client = Bitly::API::Client.new(token: ENV['BITLY_TOKEN'])
    bitlink = client.shorten(long_url: url)
    bitlink.link
  end
end
