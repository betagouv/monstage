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
      return unless user.is_a? User

      payload = {
        request_body: {
          contacts: [user_data(user: user)]
        }
      }

      response = @sendgrid_client.put(payload)

      unless response && ok_status(status: response.status_code)
        error_message = build_error_message(
          email: user.email,
          action: 'add',
          error: response_error(response: response)
        )
        Rails.logger.warn error_message
        raise error_message
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::HTTPClientError => e
      Rails.logger.error add_error_message(
        email: user.email,
        action: 'add',
        error: e
      )
      raise e
    end

    def delete_contact(email:)
      sendgrid_user_email_id = fetch_sendgrid_email_id(email: email)
      return unless sendgrid_user_email_id

      payload = { query_params: { ids: sendgrid_user_email_id } }
      response = @sendgrid_client.delete(payload)

      unless response && ok_status(status: response.status_code)
        error_message = build_error_message(
          email: email,
          action: 'remove',
          error: response_error(response: response)
        )
        Rails.logger.warn error_message
        raise error_message
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::HTTPClientError => e
      Rails.logger.error build_error_message(
        email: user.email,
        action: 'remove',
        error: e
      )
      raise e
    end

    def fetch_sendgrid_email_id(email:)
      payload = { request_body: { query: "email = '#{email}'" } }
      response = @sendgrid_client.search.post(payload)
      fetch_result = parse_result(body: response.body)

      if response && ok_status(status: response.status_code)
        fetch_result.empty? ? nil : fetch_result.first[:id]
      else
        error_message = build_error_message(
          email: email,
          action: 'fetch',
          error: response_error(response: response)
        )
        Rails.logger.warn error_message
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

    def build_error_message(email:, action:, error: '')
      # action in 'fetch' , 'add', 'remove'
      "Sendgrid api failed to #{action} #{email} to Sendgrid database - #{error}"
    end

    def response_error(response:)
      if response.nil?
        ''
      else "Status: #{response.status_code}. Erreur: " \
           "#{parse_result(response.body)}"
      end
    end
  end
end
