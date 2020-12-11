# frozen_string_literal: true

require 'test_helper'

class ZammadTicketTest < ActiveSupport::TestCase
  setup do
    @school =  create(:school, :with_school_manager)

    @headers = {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>"Bearer #{Credentials.enc(:zammad, :http_token, prefix_env: false)}",
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
    }
  end

  test 'ticket#create_ticket returns what it is stubbed for' do
    params = {
      webinar: 1,
      week_ids: [Week.first.id, Week.third.id],
      class_rooms_quantity: 3,
      students_quantity: 28,
      message: 'Test Message',
      user_id: @school.school_manager.id
    }
    service = Services::ZammadTickets::SchoolManager.new(params: params)
    stub_request(
      :post, "https://monstage.zammad.com/api/v1/tickets"
      ).with(
            body: "{\"title\":\"Demande de stage à distance | webinar\",\"group\":\"Users\",\"customer\":\"#{@school.school_manager.email}\",\"article\":{\"subject\":\"Demande de stage à distance | webinar\",\"body\":\"nombre de classes visées : 3\\nnombre d'élèves visés: 28\\ndates visées :\\n 10 octobre - 16 octobre\\n26 décembre -  1 janvier\\n-------------------------------------\\nMESSAGE : \\nTest Message\",\"type\":\"note\",\"internal\":false},\"note\":\"Stages à distance\"}",
            headers: @headers
      ).to_return(status: 200, body: "[]", headers: {})
    payload = service.create_ticket
    assert_equal [], payload
  end

  test 'ticket#create_user returns what it is stubbed for' do
    params = {
      user_id: @school.school_manager.id
    }
    service = Services::ZammadTicket.new(params: params)
    stub_request(:post, "https://monstage.zammad.com/api/v1/users").
      with(
        body: "{\"firstname\":\"#{@school.school_manager.first_name}\",\"lastname\":\"#{@school.school_manager.last_name}\",\"email\":\"#{@school.school_manager.email}\"}",
        headers: @headers
      ).to_return(status: 200, body: "\"\"", headers: {})
    payload = service.create_user
    assert_equal "", payload
  end

  test 'ticket#lookup_user returns what it is stubbed for' do
    params = {
      user_id: @school.school_manager.id
    }
    service = Services::ZammadTicket.new(params: params)
    stub_request(
      :get,
      "https://monstage.zammad.com/api/v1/users/search?query=#{@school.school_manager.email}"
    ).with(headers: @headers)
     .to_return(status: 200, body: "\"\"", headers: {})
    payload = service.lookup_user
    assert_equal "", payload
  end
end