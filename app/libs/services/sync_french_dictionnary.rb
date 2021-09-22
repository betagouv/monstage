# frozen_string_literal: true

module Services
  class SyncFrenchDictionnary
    DICTIONNARY_BASE_URL = 'https://www.dictionnaire-academie.fr/search'
    ANOMALY = ['AN'].freeze

    def search
      params = { term: word, options: '1' }
      url = URI "#{DICTIONNARY_BASE_URL}?#{params.to_query}"

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['Accept'] = 'application/json'

      https.request(request)
    ensure
      https.finish if https.try(:active?)
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

    # Available metadata are : url, label, nbhomograph, score, nature
    def metadatas(response:)
      if response_ok?(response: response)
        parse_result(body: response.body)
      else
        Rails.logger.warn 'Dictionnaire-Academie failed in ' \
                          "its seach for #{word}"
      end
    end

    def parse_result(body:)
      parsed_body = JSON.parse(body)
      parsed_body.is_a?(Hash) ? parsed_body.fetch('result', ANOMALY) : ANOMALY
    end

    def response_ok?(response:)
      return false if response.nil?

      response.code.to_i.between?(200, 299)
    end
  end
end
