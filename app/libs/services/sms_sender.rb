module Services
  class SmsSender
    LINK_MOBILITY_SENDING_ENDPOINT_URL = "https://europe.ipx.com/restapi/v1/sms/send".freeze
    def perform
      response = get_request
      if response.nil? || !response.respond_to?(:body)
        error_message = "Link Mobility error: response is ko | phone_number: " \
                        "#{@phone_number} | content: #{@content}"
        Rails.logger.error(error_message)
        return nil
      end
      response_body = JSON.parse(response.body)
      status?(0, response_body) ? log_success(response_body) : log_failure(response_body)
    end

    attr_reader :phone_number, :content , :sender_name, :user, :pass

    private

    def log_success(response_body)
      info = "Link Mobility success for phone '#{@phone_number}', with content " \
            "'#{@content}' | traceId: '#{response_body['traceId']}' | " \
            "messageIds: '#{response_body['messageIds']}'"
      Rails.logger.info(info)
      true
    end

    def log_failure(response_body)
      error_message = "Link Mobility error: '#{response_body['responseMessage']}', " \
                      "with code #{response_body['responseCode']}, for phone" \
                      " '#{@phone_number}', with content '#{@content}'"
      Rails.logger.error(error_message)
      false
    end

    def get_request
      uri = get_request_uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri, default_headers)
      http.request(request)
    end

    def get_request_uri
      URI("#{LINK_MOBILITY_SENDING_ENDPOINT_URL}?#{making_body.to_query}")
    end

    def making_body
      # maxConcatenatedMessages is 3 by default
      {
        destinationAddress: phone_number,
        messageText: content,
        username: user,
        password: pass,
        originatingAddress: sender_name,
        originatorTON: 1 # 1 = Alphanumeric, 2 = Shortcode, 3 = MSISDN
      }
    end

    #   # expected: Int|Array[Int],
    #   # response: HttpResponse
    def status?(expected, response_body)
      actual = response_body['responseCode']&.to_i
      Array(expected).include?(actual)
    end

    def default_headers
      { 'Accept': 'application/json' }
    end

    def initialize(phone_number: , content: )
      @phone_number = phone_number 
      @content = content
      @sender_name = 'Mon stage' # Max length: 16 chars
      @user = ENV['LINK_MOBILITY_USER']
      @pass = ENV['LINK_MOBILITY_SECRET']
    end
  end
end