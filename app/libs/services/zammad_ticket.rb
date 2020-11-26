# frozen_string_literal: true

module Services
  # https://docs.zammad.org/en/latest/api/ticket.html
  class ZammadTicket
    require 'net/https'

    ZAMMAD_HOST = Credentials.enc(:zammad, :url, prefix_env: false)
    TOKEN       = Credentials.enc(:zammad, :http_token, prefix_env: false)
    ENDPOINTS   = {
      tickets: {
        create: '/api/v1/tickets'
      },
      users: {
        search: '/api/v1/users/search?query=%s',
        create: '/api/v1/users'
      }
    }

    # public API
    def create_ticket
      response = post_ticket
      return JSON.parse(response.body) if status?([200, 201], response)

      raise StandardError, "fail to create ticket: code[#{response.code}], #{response.body}"
    end

    def create_user
      response = post_user
      return JSON.parse(response.body) if status?([200, 201], response)

      raise StandardError, "fail to create user: code[#{response.code}], #{response.body}"
    end

    def lookup_user
      response = search_user
      return JSON.parse(response.body) if status?([200, 201], response)

      raise StandardError, "fail to search user: code[#{response.code}], #{response.body}"
    end

    private

    attr_reader :params

    def initialize(params:)
      @params = params
      @user ||= User.find(params[:user_id])
    end

    #
    # endpoint requests
    #
    def search_user
      with_http_connection do |http|
        headers = default_headers.merge({'Content-Type' => 'application/json'})
        query = ENDPOINTS.dig(:users, :search) % @user.email
        request = Net::HTTP::Get.new(query, headers)
        http.request(request)
      end
    end

    def post_user
      with_http_connection do |http|
        headers = default_headers.merge({'Content-Type' => 'application/json'})
        request = Net::HTTP::Post.new(ENDPOINTS.dig(:users, :create), headers)
        request.body = user_payload.to_json
        http.request(request)
      end
    end

    def post_ticket
      with_http_connection do |http|
        headers = default_headers.merge({'Content-Type' => 'application/json'})
        request = Net::HTTP::Post.new(ENDPOINTS.dig(:tickets, :create), headers)
        request.body = ticket_payload.to_json
        http.request(request)
      end
    end

    def ticket_payload
      subject = 'Demande de stage à distance'
      subject = "#{subject} | webinar" if @params[:webinar].to_i == 1
      subject = "#{subject} | présentiel" if @params[:face_to_face].to_i == 1
      {
        "title": subject,
        "group": 'Users',
        "customer": @user.email,
        "article": {
          "subject": subject,
          "body": @params[:message],
          "type": 'note',
          "internal": false
        },
        "note": 'some note',
      }
    end

    def user_payload
      {
        "firstname": @user.first_name,
        "lastname": @user.last_name,
        "email": @user.email
      }
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
      uri = URI(ZAMMAD_HOST)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
        yield(https)
      ensure
        https.finish if https.try(:active?)
      end
    end

    def default_headers
      {"Authorization" => "Bearer #{TOKEN}"}
    end
  end
end

