# frozen_string_literal: true

# Since documentation is missing note these two work
# response = sendgrid_client.marketing.contacts.get # ok (parse_result(body: @sendgrid_client.get.body))
# response = sendgrid_client.marketing.lists.get # ok
# see https://github.com/sendgrid/sendgrid-ruby/issues/391#issuecomment-583059532

module Services
  class SyncEmailDelivery
    # https://github.com/sendgrid/sendgrid-nodejs/issues/953#issuecomment-511227621
    # {"0":{"id":"e2_T","name":"role","field_type":"Text","_metadata":{"self":"https://api.sendgrid.com/v3/marketing/field_definitions/e2_T"}}}
    # {"1":{"id":"e3_T","name":"monstage_id","field_type":"Text","_metadata":{"self":"https://api.sendgrid.com/v3/marketing/field_definitions/e3_T"}}}
    # Custom fields ids are copied from sendgrid rendered pages and 'hard'
    # copied (from the above HTML) to finalize a not to complex solution
    SENDGRID_CUSTOM_FIELD_IDS = {
      role: 'e2_T',
      monstage_id: 'e3_T'
    }.freeze

    def add_contact(user:)
      payload = {
        request_body: {
          contacts: [user_data(user: user)]
        }
      }
      request_with_error_handling(email: user.email, action: 'add') do
        @sendgrid_client.put(payload)
      end
    end

    def delete_contact(email:)
      sendgrid_user_email_id = fetch_sendgrid_email_id(email: email)
      return unless sendgrid_user_email_id

      payload = { query_params: { ids: sendgrid_user_email_id } }

      request_with_error_handling(email: email, action: 'remove') do
        @sendgrid_client.delete(payload)
      end
    end

    def fetch_sendgrid_email_id(email:)
      payload = { request_body: { query: "email = '#{email}'" } }
      response = @sendgrid_client.search.post(payload)
      fetch_result = parse_result(body: response.body)

      if response && ok_status(status: response.status_code)
        fetch_result.empty? ? nil : fetch_result.first[:id]
      else
        Rails.logger.warn build_error_message(
          email: email,
          action: 'fetch',
          error: response_error(response: response)
        )
      end
    end

    private

    attr_accessor :sendgrid_client

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
      custom_fields
    end

    def parse_result(body:)
      hash_response = JSON.parse body
      result = hash_response['result']
      result.is_a?(Array) ? result.map(&:symbolize_keys) : nil
    end

    def ok_status(status:)
      status.to_i.between?(200, 299)
    end

    def request_with_error_handling(email:, action:)
      response = yield
      return true if response && ok_status(status: response.status_code)

      raise  "Sendgrid api failed to #{action} #{email} to Sendgrid database"
    end
  end
end
