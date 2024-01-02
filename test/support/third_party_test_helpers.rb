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

  def ovh_stub
    stub_request(:post, "https://eu.api.ovh.com/1.0/sms/#{ENV['OVH_SMS_APPLICATION']}/jobs").
      with(
        body: "{\"message\":\"Vous êtes accepté à un stage. Confirmez votre présence : https://monstage-3e.fr/dashboard/students/1/internship_applications/1. L'équipe mon stage de troisième.\",\"noStopClause\":\"true\",\"receivers\":[\"+330612345678\"],\"sender\":\"MonStage3e\",\"validityPeriod\":2880}",
        headers: {
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
          'X-Ovh-Application'=>'',
          'X-Ovh-Consumer'=>'',
          'X-Ovh-Signature'=>'',
          'X-Ovh-Timestamp'=>''
        }).
      to_return(status: 200, body: "", headers: {})
  end
end