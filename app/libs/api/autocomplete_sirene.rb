module Api
  class AutocompleteSirene
    # see: https://api.insee.fr/catalogue/site/themes/wso2/subthemes/insee/pages/item-info.jag?name=Sirene&version=V3&provider=insee
    API_ENDPOINT = "https://api.insee.fr/entreprises/sirene/V3/siret"

    def self.search_by_siren(params:)
      uri = URI("#{API_ENDPOINT}?q=siren:#{params[:siren]}")
      headers = {
        'Authorization': "Bearer #{Rails.application.credentials.api_sirene[:token]}",
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }     
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri, headers)
      http.request(request)
    end
  end
end
