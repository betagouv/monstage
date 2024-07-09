module Services
  class SmsSender
    LINK_MOBILITY_SENDING_ENDPOINT_URL = "https://europe.ipx.com/restapi/v1/sms/send".freeze
    # TODO link mobility provider as a class variable
    def perform
      if no_sms_mode?
        treat_no_sms_message
      else
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
    end

    attr_reader :phone_number, :content , :sender_name, :user, :pass, :campaign_name

    private

    def no_sms_mode?
      ENV.fetch('NO_SMS', false) == 'true'
    end

    def treat_no_sms_message
      info = "===> No SMS mode activated | phone_number: #{@phone_number} | content: #{@content}"
      Rails.logger.info(info)
      puts '----------------------------------'
      puts info
      puts '----------------------------------'
      true
    end

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
        campaignName: campaign_name,
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

    def initialize(phone_number: , content: , campaign_name: nil)
      @phone_number = phone_number
      @campaign_name = campaign_name
      @content = content
      @sender_name = 'MonStage3e' # Max length: 16 chars
      @user = ENV['LINK_MOBILITY_USER']
      @pass = ENV['LINK_MOBILITY_SECRET']
    end
  end
end