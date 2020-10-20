module Api
  class AutocompleteAddress
    # see: https://geo.api.gouv.fr/adresse
    API_ENDPOINT = "https://api-adresse.data.gouv.fr/search"

    def self.search(params:)
      uri = URI(API_ENDPOINT)
      uri.query = URI.encode_www_form({ q: params[:q], limit: params.fetch(:limit) { 10 } })

      Net::HTTP.get(uri)
    end
  end
end
