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
        message: 'Je voudrais des stages à distance',
        week_ids: [Week.first.id],
        class_rooms_quantity: 1,
        students_quantity: 10
    }
    @headers = {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>"Bearer #{ENV['ZAMMAD_TOKEN']}",
      'Content-Type'=>'application/json',
      'User-Agent'=>'Ruby'
    }
  end

  test 'SchoolManager POST support ticket without an existing customer' do
    ticket = Services::ZammadTickets::SchoolManager.new(params: @params)
    request_url = "https://monstage.zammad.com/api/v1/users/search?query=#{@user.email}"
    stub_request(:get, request_url).with( headers: @headers )
                                   .to_return(status: 200, body: "[]", headers: {})
    stub_request(:post, "https://monstage.zammad.com/api/v1/users")
      .with(body: ticket.send(:user_payload).as_json, headers: @headers)
      .to_return(status: 200, body: "{}", headers: {})

    stub_request(:post, "https://monstage.zammad.com/api/v1/tickets")
      .with(body: ticket.send(:ticket_payload).as_json, headers: @headers)
      .to_return(status: 200, body: "{}", headers: {})
    SupportTicketJobs::SchoolManager.new(params: @params).perform_now
  end

  test 'SchoolManager POST support ticket with an existing customer' do
    ticket = Services::ZammadTickets::SchoolManager.new(params: @params)
    request_url = "https://monstage.zammad.com/api/v1/users/search?query=#{@user.email}"
    stub_request(:get, request_url).with( headers: @headers )
                                   .to_return(status: 200, body: "[\"someone\"]", headers: {})
    stub_request(:post, "https://monstage.zammad.com/api/v1/tickets")
      .with(body: ticket.send(:ticket_payload).as_json, headers: @headers)
      .to_return(status: 200, body: "{}", headers: {})

    SupportTicketJobs::SchoolManager.new(params: @params).perform_now
  end

  test 'Employer POST support ticket with an existing customer' do
    ticket = Services::ZammadTickets::Employer.new(params: @params)
    request_url = "https://monstage.zammad.com/api/v1/users/search?query=#{@user.email}"
    stub_request(:get, request_url).with( headers: @headers)
                                   .to_return(status: 200, body: "[\"someone\"]", headers: {})

    stub_request(:post, "https://monstage.zammad.com/api/v1/tickets")
      .with(body: ticket.send(:ticket_payload).as_json, headers: @headers)
      .to_return(status: 200, body: "{}", headers: {})

    SupportTicketJobs::Employer.new(params: @params).perform_now
  end

end
