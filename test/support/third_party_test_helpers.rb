module ThirdPartyTestHelpers
  def bitly_stub
    stub_request(:post, "https://api-ssl.bitly.com/v4/shorten").
        with(
          body: "{\"long_url\":\"http://example.com/dashboard/248/internship_applications/1520\"}",
          headers: {
                'Accept'=>'application/json',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization'=>'Bearer ',
                'Content-Type'=>'application/json',
                'User-Agent'=>'Ruby Bitly/2.0.1'
          }).
        to_return(status: 200, body: "", headers: {})
  end
end