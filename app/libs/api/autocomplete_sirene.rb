module Api
  class AutocompleteSirene
    # see: https://geo.api.gouv.fr/adresse
    API_ENDPOINT = "https://api.insee.fr/entreprises/sirene/siret"
    API_ENTREPRISE_ENDPOINT = "https://recherche-entreprises.api.gouv.fr/search"


    def self.search_by_siret(siret:)
      self.check_token
      uri = URI("#{API_ENDPOINT}/#{siret}")
      headers = {
        'Authorization': "Bearer #{@token}",
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri, headers)

      http.request(request)
    end

    def self.search_by_name(name:)
      return  nil unless name.present?
      uri = URI::Parser.new.parse("#{API_ENTREPRISE_ENDPOINT}?q=#{CGI.escape(name)}")
      headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri, headers)

      http.request(request)
    end

    def self.check_token
      @token = Rails.cache.read 'sirene_token'
      self.fetch_new_token unless @token
    end

    def self.fetch_new_token
      uri = URI.parse("https://api.insee.fr/token")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Basic #{ENV['API_SIRENE_SECRET']}"
      request.set_form_data(
        "grant_type" => "client_credentials",
      )

      req_options = {
        use_ssl: uri.scheme == "https",
        verify_mode: OpenSSL::SSL::VERIFY_NONE,
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      @token = JSON.parse(response.body)['access_token']
      Rails.cache.write('sirene_token', @token)
    end
  end


end
