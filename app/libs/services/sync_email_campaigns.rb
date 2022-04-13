# frozen_string_literal: true

module Services
  # https://dev.mailjet.com/email/reference/overview/
  class SyncEmailCampaigns
    require 'net/https'

    SARBACANE_HOST = 'https://sarbacaneapis.com/v1'.freeze

    SARBACANE_ENDPOINTS = {
      list:{
        add: { url_part: '/lists', method: :post },
        read: { url_part: '/lists', method: :get }
      }
    }.freeze

    # public API

    def read_lists
      response = fetch_lists
      return JSON.parse(response.body) if status?(200, response)

      raise StandardError.new "fail to list metadata: code[#{response.code}], #{response.body}"
    end

    private

    def uri_extension(url_parts:[], parameter: nil)
      return SARBACANE_ENDPOINTS.dig(*url_parts)[:url_part] if parameter.nil?

      SARBACANE_ENDPOINTS.dig(*url_parts)[:url_part] % parameter
    end

    def do_request(url_parts:[], default_header: default_headers, parameter: nil)
      uri_str = uri_extension(url_parts: url_parts, parameter: parameter)
      full_endpoint = "#{SARBACANE_HOST}/#{uri_str}"
      method = SARBACANE_ENDPOINTS.dig(*url_parts)[:method]
      case method
      when :get
        Net::HTTP::Get.new(full_endpoint, default_header)
      when :post
        Net::HTTP::Post.new(full_endpoint, default_header)
      when :put
        Net::HTTP::Put.new(full_endpoint, default_header)
      when :delete
        Net::HTTP::Delete.new(full_endpoint, default_header)
      else
        Net::HTTP::Get.new(full_endpoint, default_header)
      end
    end

    def fetch_lists
      with_http_connection do |http|
        http.request(
          do_request(url_parts: [:list, :read])
        )
      end
    end

    # expected: Int|Array[Int],
    # response: HttpResponse
    def status?(expected, response)
      actual = response.code.to_i
      Array(expected).include?(actual)
    end

    #
    # utils
    #
    def with_http_connection(&block)
      uri = URI(SARBACANE_HOST)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
        yield(https)
      end
    end

    def default_headers
      user = ENV['SARBACANE_ACCOUNT_ID']
      pass = ENV['SARBACANE_API_KEY']

      auth = ActionController::HttpAuthentication::Basic.encode_credentials(user, pass)

      # { 'Authorization' => auth }
      { 'Authorization' => auth, 'Content-Type' => 'application/json' }
    end
  end
end
