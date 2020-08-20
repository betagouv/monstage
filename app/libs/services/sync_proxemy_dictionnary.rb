module Services
  class SyncProxemyDictionnary # rubocop:todo Style/Documentation
    include NetUtil

    SYNONYM_DICT_BASE_URL = 'http://autourdumot.fr/tmuse_v1/subgraph/play'.freeze
    SEARCH_RESULT_MAX_NUMBER = 50
    ANOMALY = ['AN'].freeze

    def search
      params = make_params(word: word, result_length: SEARCH_RESULT_MAX_NUMBER)
      json_post_query(
        resource_url: SYNONYM_DICT_BASE_URL,
        params: params,
        use_ssl: false
      )
    end

    def synonyms
      metas = metadatas(response: search)
      return [] if metas.nil?

      metas.select { |meta| meta['score'].to_f > 0.75 }
           .sort_by { |meta| meta['score'].to_f }
           .reverse
           .map { |meta| meta['label'] }
           .difference([word])
    end

    # ==================
    private

    attr_reader :word

    def initialize(word:)
      @word = word
    end

    def metadatas(response:)
      if response_ok?(response: response)
        parse_result(body: response.body)
      else
        Rails.logger.warn "#{URI(SYNONYM_DICT_BASE_URL).host} failed in " \
                          "its seach for #{word}"
      end
    end

    def parse_result(body:)
      parsed_body = JSON.parse(body)
      return ANOMALY unless parsed_body.is_a?(Hash)

      parsed_body.dig('results', 'clusters', 'labels') || ANOMALY
    end

    def make_params(word:, result_length:)
      {
        query: [
          {
            graph: 'null',
            lang: 'fr',
            pos: 'N',
            form: word,
            boost: 1,
            valid: false
          },
          {
            graph: 'null',
            lang: 'fr',
            pos: 'N',
            form: word,
            boost: 1,
            valid: false
          }
        ],
        options: {
          graph: [
            {
              name: 'GraphSearch|VtxAttr|VtxAttr',
              options: {
                length: result_length
              }
            }
          ],
          clustering: [{ name: 'EdgeAttr|Infomap' }],
          layout: [{ name: 'ByConnectedComponent|normalise' }]
        }
      }
    end
  end
end
