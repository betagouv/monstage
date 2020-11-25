# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class InternshipApplicationsTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @school = create(:school, :with_school_manager)
        sign_in(@school.school_manager)

        @params = {
          support_ticket: {
            first_name: 'Jean',
            last_name: 'Dujardin',
            subject: '[Demande de stage à distance]',
            email: @school.school_manager.email,
            webinar: 1,
            message: 'Je voudrais des stages à distance'
          }
        }
        @headers = {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>"Bearer #{Credentials.enc(:zammad, :http_token, prefix_env: false)}",
          'Content-Type'=>'application/json',
          'User-Agent'=>'Ruby'
        }

        stub_request(
          :get, "https://monstage.zammad.com/api/v1/users/search?query=#{@params[:support_ticket][:email]}"
        ).with(
          headers: @headers
        ).to_return(status: 200, body: "[\"someone\"]", headers: {})

        stub_request(
          :post, "https://monstage.zammad.com/api/v1/tickets"
        ).with(
          body: "{\"title\":\"Demande de stage à distance | webinar\",\"group\":\"Users\",\"customer\":\"#{@params[:support_ticket][:email]}\",\"article\":{\"subject\":\"Demande de stage à distance | webinar\",\"body\":\"Je voudrais des stages à distance\",\"type\":\"note\",\"internal\":false},\"note\":\"some note\"}",
          headers: @headers
        ).to_return(status: 200, body: "{}", headers: {})
      end


      #
      # update by group
      #
      test 'POST support ticket with an existing customer' do
        post dashboard_school_support_tickets_path(@school, params: @params) do |result|
          assert_equal 'true', result[:success]
        end
      end

      test 'POST support ticket without an existing customer' do
        stub_request(
          :post, "https://monstage.zammad.com/api/v1/users"
        ).with(
          body: "{\"firstname\":\"Jean\",\"lastname\":\"Dujardin\",\"email\":\"#{@params[:support_ticket][:email]}\"}",
          headers: @headers
        ).to_return(status: 200, body: "", headers: {})

        post dashboard_school_support_tickets_path(@school, params: @params) do |result|
          assert_equal 'true', result[:success]
        end
      end
    end
  end
end
