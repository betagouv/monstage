# frozen_string_literal: true

module Services
  class SyncFrenchDictionnary
    include NetUtil

    DICTIONNARY_BASE_URL = 'https://www.dictionnaire-academie.fr/search'
    ANOMALY = ['AN'].freeze

    def search
      params = { term: word, options: '1' }
      post_query(resource_url: DICTIONNARY_BASE_URL, params: params)
    end

    def natures
      metas = metadatas(response: search)
      return [] if metas.nil?

      metas.select { |meta| meta['score'].to_f > 0.9 }
           .map { |meta| meta['nature'] }
           .sort
           .uniq
    end

    def exists?
      natures.count.positive?
    end

    private

    attr_reader :word

    def initialize(word:)
      @word = word
    end

    def metadatas(response:)
      if response_ok?(response: response)
        parse_result(body: response.body)
      else
        Rails.logger.warn "#{URI(DICTIONNARY_BASE_URL).host} failed in " \
                          "its seach for #{word}"
      end
    end

    def parse_result(body:)
      # Available metadata are : url, label, nbhomograph, score, nature
      parsed_body = JSON.parse(body)
      return ANOMALY unless parsed_body.is_a?(Hash)

      parsed_body.fetch('result', ANOMALY)
    end
  end
end
