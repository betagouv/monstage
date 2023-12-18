# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default
  LINK_MOBILITY_SENDING_ENDPOINT_URL = "https://europe.ipx.com/restapi/v1/sms/send"
  # LINK_MOBILITY_PERMANENT_ERRORS = [
  #   15, # Message concatenation limit exceeded
  #   103, # Invalid account name
  #   117, # Invalid campaign name
  # ].freeze

  def perform(user: , content: , phone_number: nil)

    return if user.phone.blank?
    return if content.blank? || content.length > 318


    @phone_number = phone_number || User.sanitize_mobile_phone_number(user.phone, '33')
    @content = content
    @sender_name = 'Monstage'
    @user = ENV['LINK_MOBILITY_USER']
    @pass = ENV['LINK_MOBILITY_SECRET']

    puts '================'
    puts "@phone_number : #{@phone_number}"
    puts '================'
    puts ''

    send_with_netsize
  end

  # def perform(user:, message:)
  #   if user.formatted_phone.nil?
  #     error_message = "sms [user_id = #{user.id}] to be sent with empty phone number !"
  #     Rails.logger.error(error_message) && return
  #   end

  #   client = OVH::REST.new(
  #     ENV['OVH_APPLICATION_KEY'],
  #     ENV['OVH_APPLICATION_SECRET'],
  #     ENV['OVH_CONSUMMER_KEY']
  #   )
  #   response = client.post("/sms/#{ENV['OVH_SMS_APPLICATION']}/jobs",
  #                          {
  #                            'sender': ENV['OVH_SENDER'],
  #                            'message': message,
  #                            'receivers': [user.formatted_phone],
  #                            'noStopClause': 'true'
  #                          })
  # end


  #  def save_receipt(**args)
  #     params = @receipt_params.merge({ channel: :sms, sms_provider: @provider, sms_phone_number: @phone_number, content: @content }, args)
  #     Receipt.create!(params)
  #  end

  # def handle_failure(error_message:, retry_job: true)
  #     save_receipt(result: :failure, error_message: error_message)

  #     if retry_job
  #       raise SmsSenderFailure, error_message
  #     else
  #       Sentry.capture_message(error_message)
  #     end
  #   end


  # These errors should not trigger a retry, because it would only fail again


    # NetSize
    # `Netsize Implementation Guide, REST API - SMS.pdf`
    # returns routing errors for wrong numbers
    #
    # Utilisé par défaut pour toutes les structures (territoires) utilisant
    # RDV-Solidarités, sauf celle cité dans les autres commentaires.
    #
    # request = Typhoeus::Request.new(
    #   LINK_MOBILITY_SENDING_ENDPOINT_URL,
    #   method: :post,
    #   userpwd: @api_key,
    #   headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
    #   timeout: 5,
    #   body: {
      #     destinationAddress: @phone_number,
    #     messageText: @content,
    #     originatingAddress: @sender_name,
    #     originatorTON: 1,
    #     maxConcatenatedMessages: 10,
    #   }
    # )

    # request.on_success do |response|
    #   parsed_response = JSON.parse(response.body)
    #   # parsed_response is a hash. Relevant keys are:
    #   # responseCode: nonzero on error. 18 is “Too low balance”, 100 is “Invalid destination address”.
    #   # responseMessage: error description, in english “Success” if responseCode is zero.
    #   # timestamp: Date & time when Netsize processed the request
    #   # traceId: Netsize internal identifier (for debugging purposes)
    #   # messageIds: Array of Netsize unique message, if the message was split. Ignored on error.
    #   if parsed_response["responseCode"].zero?
    #     save_receipt(result: :delivered, sms_count: parsed_response["messageIds"]&.count)
    #   else
    #     retry_job = !parsed_response["responseCode"].in?(LINK_MOBILITY_PERMANENT_ERRORS)
    #     handle_failure(error_message: "NetSize error: #{parsed_response['responseMessage']}", retry_job: retry_job)
    #   end
    # end

    # request.on_failure do |response|
    #   if response.timed_out?
    #     handle_failure(error_message: "NetSize timeout")
    #   elsif response.failure?
    #     handle_failure(error_message: "NetSize HTTP error: #{response.code}")
    #   end
    # end

    # request.run
    # puts '================'
    # puts "full_endpoint : #{full_endpoint}"
    # puts '================'
    # puts ''
    # response = Net::HTTP::Get.new(full_endpoint)
    # 
    #  # def full_endpoint
    #   body = making_body.merge(
    #     username: ENV['LINK_MOBILITY_USER'],
    #     password: ENV['LINK_MOBILITY_SECRET'],
    #     )
    #   "#{LINK_MOBILITY_SENDING_ENDPOINT_URL}?#{body.to_query}"
    # end
    # 
  def send_with_netsize
    puts '================'
    puts "making_body : #{making_body}"
    puts '================'
    puts ''
    response = send_request(body: making_body)
    if response.nil? || !response.is_a?(Net::HTTPOK)
      Rails.logger.error("NetSize error: response class: #{response.class}")
      return
    end
    response_body = JSON.parse(response.body)
    status?(0, response_body) ? log_success(response_body) : log_failure(response_body)
    true
  end

  def log_success(response_body)
    info = "NetSize success for phone '#{@phone_number}', with content " \
           "'#{@content}' | traceId: '#{response_body['traceId']}' | " \
           "messageIds: '#{response_body['messageIds']}'"
    Rails.logger.info(info)
  end

  def log_failure(response_body)
    error_message = "NetSize error: '#{response_body['responseMessage']}', " \
                    "with code #{response_body['responseCode']}, for phone" \
                    " '#{@phone_number}', with content '#{@content}'"
    puts '================'
    puts "error_message : #{error_message}"
    puts '================'
    Rails.logger.error(error_message)
  end


  private

  def making_body
    # maxConcatenatedMessages is 3 by default
    {
      destinationAddress: @phone_number,
      messageText: @content,
      originatingAddress: @sender_name,
      originatorTON: 1
    }
  end

  #TODO mutualize these methods in a module

  def send_request(body:)
     with_http_connection do |http|
      http.request(do_request(body: making_body.to_json))
    end
  end

  def with_http_connection(&block)
    uri = URI(LINK_MOBILITY_SENDING_ENDPOINT_URL)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
      yield(https)
    end
  end

  def do_request(body:, default_header: default_headers)
    Net::HTTP::Post.new(LINK_MOBILITY_SENDING_ENDPOINT_URL, default_header).tap do |request|
      request.body = body
    end
  end

  #   # expected: Int|Array[Int],
  #   # response: HttpResponse
  def status?(expected, response_body)
    actual = response_body[:responseCode]&.to_i
    Array(expected).include?(actual)
  end

  def default_headers
    auth = ActionController::HttpAuthentication::Basic.encode_credentials(@user, @pass)

    {
      'Authorization' => auth,
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end
end
