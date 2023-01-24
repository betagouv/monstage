module StubsForApiGouvRequests
  def stub_gouv_api_requests
    stub_request(:post, "https://api.insee.fr/token").
      with(
        body: {"grant_type"=>"client_credentials"},
        headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>"Basic #{ENV['API_SIRENE_SECRET']}",
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Host'=>'api.insee.fr',
              'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: {access_token: 'TOKEN'}.to_json, headers: {})

  #---------
    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            api-insee-adresse-east-side-software.json]
      )
    )
    stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3/siret?q=siret:90943224700015").
      with(
        headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer TOKEN',
              'Content-Type'=>'application/json',
              'Host'=>'api.insee.fr',
              'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: body, headers: {})
    stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3/siret?q=siret:undefined").
          with(
            headers: {
                  'Accept'=>'application/json',
                  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Authorization'=>'Bearer TOKEN',
                  'Content-Type'=>'application/json',
                  'Host'=>'api.insee.fr',
                  'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: body, headers: {})
  end
end