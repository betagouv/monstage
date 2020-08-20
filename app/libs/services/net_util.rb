module Services
  module NetUtil
    extend ActiveSupport::Concern

    included do
      def post_query(resource_url:, params:, use_ssl: true)
        url = URI "#{resource_url}?#{params.to_query}"
        request, https = net_search_for_post(url: url, use_ssl: use_ssl)
        https.request(request)
      ensure
        https.finish if https.try(:active?)
      end

      def json_post_query(resource_url:, params:, use_ssl: true)
        url = URI resource_url
        request, https = net_search_for_post(url: url, use_ssl: use_ssl)
        request['Content-Type'] = 'application/json'
        request.body = params.to_json
        https.request(request)
      ensure
        https.finish if https.try(:active?)
      end

      def net_search_for_post(url:, use_ssl:)
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true if use_ssl

        request = Net::HTTP::Post.new(url)
        request['Accept'] = 'application/json'
        [request, https]
      end

      def response_ok?(response:)
        return false if response.nil?

        response.code.to_i.between?(200, 299)
      end
    end
  end
end
