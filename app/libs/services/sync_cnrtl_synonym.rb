module Services
  class SyncCnrtlSynonym
    require 'open-uri'

    SYNONYM_DICT_BASE_URL = 'https://www.cnrtl.fr/synonymie'.freeze

    def synonyms
      metadatas(document: page_search)
    end

    def page_search
      url = "#{SYNONYM_DICT_BASE_URL}/#{word}"
      begin
        uri = URI.parse(url)
      rescue URI::InvalidURIError
        uri = URI.parse(CGI.escape(url))
      end
      Nokogiri::HTML(uri.open)
    end

    # ==================
    private

    attr_reader :word

    def initialize(word:)
      @word = word
    end

    def metadatas(document:)
      if document.is_a?(Nokogiri::HTML::Document)
        parse_result(document: document)
      else
        Rails.logger.warn "#{URI(SYNONYM_DICT_BASE_URL).host} failed while " \
                          "loading html page for #{word} synonyms"
      end
    end

    def parse_result(document:)
      synonyms = []
      document.xpath("//*[@class='syno_format']/a").each do |a_tag|
        synonyms << a_tag.text
      end
      synonyms
    end
  end
end
