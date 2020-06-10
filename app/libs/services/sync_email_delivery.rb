# frozen_string_literal: true

module Services
  class SyncEmailDelivery

    SENDGRID_CUSTOM_FIELD_IDS = {
      role: 'e2_T',
      monstage_id: 'e3_T',
      type: 'e4_T',
      environment: 'e5_T',
      confirmed_at: 'e6_T'
    }.freeze

    def add_contact(user:)
      return if fetch_sendgrid_email_id(email: user.email)

      payload = {
        request_body: {
          contacts: [user_data(user: user)]
        }
      }
      request_with_error_handling(email: user.email, action: 'add') do
        sendgrid_client.put(payload)
      end
    end

    def delete_contact(email:)
      sendgrid_user_email_id = fetch_sendgrid_email_id(email: email)
      return unless sendgrid_user_email_id

      payload = { query_params: { ids: sendgrid_user_email_id } }

      request_with_error_handling(email: email, action: 'remove') do
        sendgrid_client.delete(payload)
      end
    end

    def fetch_sendgrid_email_id(email:)
      payload = { request_body: { query: "email = '#{email}'" } }
      response = sendgrid_client.search.post(payload)

      if response_ok?(response: response)
        fetch_result = parse_result(body: response.body)
        fetch_result.empty? ? nil : fetch_result.first[:id]
      else
        Rails.logger.warn "Sendgrid api failed to fetch #{email}" \
                          ' in Sendgrid database'
      end
    end

    private

    attr_reader :sendgrid_client

    def initialize
      api_key = Rails.application.credentials[:sendgrid][:api_key]
      @sendgrid_client = SendGrid::API.new(api_key: api_key)
                                      .client
                                      .marketing
                                      .contacts
    end

    def user_data(user:)
      {
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "custom_fields": custom_fields(user: user)
      }
    end

    def custom_fields(user:)
      # Sendgrid do not allow nil(blank?) custom fields
      custom_fields = {}
      custom_fields[SENDGRID_CUSTOM_FIELD_IDS[:role]] = user&.role || 'N/A'
      custom_fields[SENDGRID_CUSTOM_FIELD_IDS[:monstage_id]] = user.id.to_s
      custom_fields[SENDGRID_CUSTOM_FIELD_IDS[:type]] = user.type
      custom_fields[SENDGRID_CUSTOM_FIELD_IDS[:environment]] = Rails.env
      custom_fields
    end

    def parse_result(body:)
      hash_response = JSON.parse body
      result = hash_response['result']
      result.is_a?(Array) ? result.map(&:symbolize_keys) : nil
    end

    def response_ok?(response:)
     return false if response.nil?

     response.status.to_i.between?(200, 299)
    end

    def request_with_error_handling(email:, action:)
      response = yield
      return true if response_ok?(response: response)

      raise  "Sendgrid api failed to #{action} #{email} to Sendgrid database"
    end
  end
end
