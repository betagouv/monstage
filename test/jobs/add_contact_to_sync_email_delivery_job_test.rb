# frozen_string_literal: true

require 'test_helper'

class AddContactToSyncEmailDeliveryJobTest < ActiveJob::TestCase
  test 'without existing user' do
    user = create(:employer)
    api = Services::SyncEmailDelivery.new
    auth = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['MAILJET_API_KEY_PUBLIC'], ENV['MAILJET_API_KEY_PRIVATE'])
    data = [
      {
        "CreatedAt"=>"2020-12-16T14:23:06Z",
        "DeliveredCount"=>0,
        "Email"=>"#{user.email}",
        "ExclusionFromCampaignsUpdatedAt"=>"",
        "ID"=>1417876632,
        "IsExcludedFromCampaigns"=>false,
        "IsOptInPending"=>false,
        "IsSpamComplaining"=>false,
        "LastActivityAt"=>"",
        "LastUpdateAt"=>"",
        "Name"=>"User Users::employer",
        "UnsubscribedAt"=>"",
        "UnsubscribedBy"=>""
      }
    ]
    headers = {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>auth,
      'User-Agent'=>'Ruby'
    }
    json_error = {
      "ErrorInfo"=>"",
      "ErrorMessage"=>"Unexpected error during GET: Invalid email address \"asdasd\",
      reason: \"No @ character in mail\"",
      "StatusCode"=>400
    }.to_json
    special_name="#{user.first_name.downcase.capitalize} #{user.last_name}"
    travel_to(Date.new(2019, 3, 1)) do
      stub_request(:get, "https://api.mailjet.com/v3/REST/contact/#{user.email}").
            with( headers: headers).to_return(status: 400, body: json_error, headers: {})

      stub_request(:post, "https://api.mailjet.com/v3/REST/contact").
            with(
              body: api.send(:make_create_contact_payload, user: user).to_json, headers: headers)
                       .to_return(
                         status: 201,
                         body: {"Count"=>1, "Data"=>data, "Total"=>1}.to_json,
                         headers: {})

      stub_request(:put, "https://api.mailjet.com/v3/REST/contactdata/#{user.email}").
            with(
              body: api.send(:make_update_contact_payload, user: user).to_json, headers: headers)
                       .to_return(status: 200, body: "{}", headers: {})
      AddContactToSyncEmailDeliveryJob.perform_now(user: user)
    end
  end
end
