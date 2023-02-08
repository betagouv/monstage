# frozen_string_literal: true

module Services
  class SyncEmailCampaigns
    require 'net/https'

    SARBACANE_HOST = 'https://sarbacaneapis.com/v1'.freeze

    SARBACANE_ENDPOINTS = {
      list:{
        add: { url_part: '/lists', method: :post },
        read: { url_part: '/lists', method: :get }
      },
      contact:{
        add: { url_part: '/lists/%s/contacts', method: :post },
        search: { url_part: '/lists/%s/contacts', method: :get },
        delete: { url_part: '/lists/%s/contacts', method: :delete }
      }
    }.freeze

    # public API
    def add_contact(user:, list_name: 'newsletter')
      list_id = fetch_list_id({list_name: list_name})
      return :unexisting_list if list_id.blank?

      search_result = search_contact_by_email(email: user.email, list_id: list_id)
      return :previously_existing_email unless search_result.nil?

      response = add_contact_to_list(list_id: list_id, user: user)
      return JSON.parse(response.body) if status?(200, response)

      raise StandardError.new "Fail to add_contact ##{user.id} in #{list_name}"
    end

    def remove_contact(email:, list_name: 'newsletter')
      list_id = fetch_list_id(list_name: list_name)
      return :unexisting_list if list_id.blank?

      search_result = search_contact_by_email(email: email, list_id: list_id)
      return :unexisting_email if search_result.nil?

      response = delete_contact_from_list(list_id: list_id, email: email)
      return true if status?(200, response)

      raise StandardError.new "fail to remove contact #{email} from #{list_name}: code[#{response.code}], #{response.body}"
    end


    private

    def list_contacts(list_id:)
      response = fetch_contacts(list_id: list_id)
      return JSON.parse(response.body) if status?(200, response)

      raise StandardError.new "fail to list contacts #{list_name} list: code[#{response.code}], #{response.body}"
    end

    def read_lists
      response = fetch_lists
      return JSON.parse(response.body) if status?(200, response)

      raise StandardError.new "fail to list metadata: code[#{response.code}], #{response.body}"
    end

    # Browser methods

    def fetch_list_id(list_name: )
      campaign_lists = read_lists

      campaign_lists.each do |list|
        return list['id'] if list['name'] == list_name
      end
      ""
    end


    def search_contact_by_email(email:, list_id:)
      contacts = list_contacts(list_id: list_id)
      return if contacts.empty?

      contacts.each do |contact|
        return contact if contact['email'] == email
      end
      nil
    end

    #
    #Requests
    #

    def fetch_lists
      with_http_connection do |http|
        http.request(
          do_request(url_parts: %i[list read])
        )
      end
    end

    def add_contact_to_list(list_id: , user:)
      with_http_connection do |http|
        body = { email: user.email, phone: user.phone }.to_json
        http.request(
          do_request(url_parts: %i[contact add], parameter: list_id, body: body)
        )
      end
    end

    def fetch_contacts(list_id:)
      with_http_connection do |http|
        http.request(
          do_request(url_parts: %i[contact search], parameter: list_id)
        )
      end
    end

    def delete_contact_from_list(list_id: , email:)
      with_http_connection do |http|
        params = { email: email }
        http.request(
          do_request(url_parts: %i[contact delete], parameter: list_id, params: params)
        )
      end
    end

    #
    # utils
    #

    def full_endpoint(url_parts:, parameter: , params: )
      url = SARBACANE_ENDPOINTS.dig(*url_parts)[:url_part]
      url = SARBACANE_ENDPOINTS.dig(*url_parts)[:url_part] % parameter if parameter.present?
      url = "#{SARBACANE_HOST}/#{url}"
      return url if params.blank?

      "#{url}?#{params.to_query}"
    end

    def do_request(url_parts: , default_header: default_headers, parameter: nil, body: nil, params:{})
      full_endpoint = full_endpoint(url_parts: url_parts, parameter: parameter, params: params)
      case SARBACANE_ENDPOINTS.dig(*url_parts)[:method]
      when :get
        Net::HTTP::Get.new(full_endpoint, default_header)
      when :post
        Net::HTTP::Post.new(full_endpoint, default_header).tap do |request|
          request.body = body if body.present?
        end
      when :put
        # Net::HTTP::Put.new(full_endpoint, default_header)
      when :delete
        Net::HTTP::Delete.new(full_endpoint, default_header).tap do |request|
          request.body = body if body.present?
        end
      else
        Net::HTTP::Get.new(full_endpoint, default_header)
      end
    end

    # expected: Int|Array[Int],
    # response: HttpResponse
    def status?(expected, response)
      actual = response.code.to_i
      Array(expected).include?(actual)
    end

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

      { 'Authorization' => auth, 'Content-Type' => 'application/json' }
    end
  end
end
