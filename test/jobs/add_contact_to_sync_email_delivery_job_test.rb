# frozen_string_literal: true

require 'test_helper'

class AddContactToSyncEmailDeliveryJobTest < ActiveJob::TestCase
  test 'without existing user' do
    user = create(:employer)
    api = Services::SyncEmailDelivery.new
    stub_request(:get, "https://api.mailjet.com/v3/REST/contact/#{user.email}").
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Basic NzgzOWFkNTU3OGI3MWFlMmM1ZDQzYmZlOGI2YzcwMjA6MTYwY2VhZTI3MWE1NjdlMmRlYTc5ZDdmOWQyYTZiNWY=',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 400, body:  {"ErrorInfo"=>"", "ErrorMessage"=>"Unexpected error during GET: Invalid email address \"asdasd\", reason: \"No @ character in mail\"", "StatusCode"=>400}.to_json, headers: {})

    stub_request(:post, "https://api.mailjet.com/v3/REST/contact").
          with(
            body: "{\"IsExcludedFromCampaigns\":false,\"name\":\"Jean claude Dus\",\"email\":\"jean1-claude@dus.fr\"}",
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Basic NzgzOWFkNTU3OGI3MWFlMmM1ZDQzYmZlOGI2YzcwMjA6MTYwY2VhZTI3MWE1NjdlMmRlYTc5ZDdmOWQyYTZiNWY=',
            'Content-Type'=>'application/json',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 201, body: {"Count"=>1, "Data"=>[{"CreatedAt"=>"2020-12-16T14:23:06Z", "DeliveredCount"=>0, "Email"=>"employer@ms3e.fr", "ExclusionFromCampaignsUpdatedAt"=>"", "ID"=>1417876632, "IsExcludedFromCampaigns"=>false, "IsOptInPending"=>false, "IsSpamComplaining"=>false, "LastActivityAt"=>"", "LastUpdateAt"=>"", "Name"=>"User Users::employer", "UnsubscribedAt"=>"", "UnsubscribedBy"=>""}], "Total"=>1}.to_json, headers: {})

    stub_request(:put, "https://api.mailjet.com/v3/REST/contactdata/jean1-claude@dus.fr").
          with(
            body: api.send(:make_update_contact_payload, user: user).to_json,
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Basic NzgzOWFkNTU3OGI3MWFlMmM1ZDQzYmZlOGI2YzcwMjA6MTYwY2VhZTI3MWE1NjdlMmRlYTc5ZDdmOWQyYTZiNWY=',
            'Content-Type'=>'application/json',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: "{}", headers: {})

    AddContactToSyncEmailDeliveryJob.perform_now(user: user)
  end
end
