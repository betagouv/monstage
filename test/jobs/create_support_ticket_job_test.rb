# frozen_string_literal: true

require 'test_helper'

class CreateSupportTicketJobTest < ActiveJob::TestCase

  setup do
    @school = create(:school, :with_school_manager)
    @user = @school.school_manager
    @params = {
        subject: '[Demande de stage à distance]',
        user_id: @user.id,
        webinar: 1,
        message: 'Je voudrais des stages à distance'
    }
    @headers = {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>"Bearer #{Credentials.enc(:zammad, :http_token, prefix_env: false)}",
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
    }

    stub_request(
      :post, "https://monstage.zammad.com/api/v1/tickets"
    ).with(
      body: "{\"title\":\"Demande de stage à distance | webinar\",\"group\":\"Users\",\"customer\":\"#{@user.email}\",\"article\":{\"subject\":\"Demande de stage à distance | webinar\",\"body\":\"Je voudrais des stages à distance\",\"type\":\"note\",\"internal\":false},\"note\":\"some note\"}",
      headers: @headers
    ).to_return(status: 200, body: "{}", headers: {})
  end

  test 'POST support ticket with an existing customer' do
    request_url = "https://monstage.zammad.com/api/v1/users/search?query=#{@user.email}"
    stub_request(:get, request_url).with( headers: @headers )
                                   .to_return(status: 200, body: "[\"someone\"]", headers: {})

    CreateSupportTicketJob.new(params: @params).perform_now
  end

  test 'POST support ticket without an existing customer' do
    request_url = "https://monstage.zammad.com/api/v1/users/search?query=#{@user.email}"
    stub_request(:get, request_url).with( headers: @headers )
                                   .to_return(status: 200, body: "[]", headers: {})

    body = "{\"firstname\":\"#{@user.first_name}\",\"lastname\":\"#{@user.last_name}\",\"email\":\"#{@user.email}\"}"
    returned_value =  "{\"id\":123,\"firstname\":\"#{@user.first_name}\",\"lastname\":\"#{@user.last_name}\"}"
    stub_request(:post, "https://monstage.zammad.com/api/v1/users").with(
      body: body,
      headers: @headers
    ).to_return(status: 200, body: returned_value, headers: {})

    CreateSupportTicketJob.new(params: @params).perform_now
  end
end
