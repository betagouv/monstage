module Services
  class SchoolDirectory
    include Phonable
    DIRECTORY_BASE_URL = 'https://www.education.gouv.fr/annuaire'

    def school_data_search
      result = fetch_data
      result = second_try if result.nil?
      result = third_try if result.nil?
      formatted_phone = result[:phone].nil? ? "" : french_phone_number_format(result[:phone])
      address = result[:address].nil? ? "" : sanitize(result[:address])
      email = result[:email].nil? ? "" : result[:email]
      school.update(fetched_school_phone: formatted_phone, fetched_school_address: address, fetched_school_email: email)
      result
    end

    private

    attr_accessor :searched_school_name, :department, :school
    attr_reader :code_uai

    def initialize(school:)
      @school = school
      @searched_school_name = school.name
      @department = Department.key_for_lookup(zipcode: school.zipcode)
      @code_uai = school.code_uai.downcase
    end

    def fetch_data
      fetch_data_in_page(response: search_request)
    end

    def second_try
      @searched_school_name = "Collège #{searched_school_name}"
      fetch_data
    end

    def third_try
      @department = ''
      fetch_data
    end

    def search_request
      params = { keywords: searched_school_name,
                 department: department, # 2 figures
                 status: 'All',
                 establishment: '2' } # 2 is for collège
      url = URI "#{DIRECTORY_BASE_URL}?#{params.to_query}"

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request['Accept'] = 'text/html'

      https.request(request)
    ensure
      https.finish if https.try(:active?)
    end

    def fetch_data_in_page(response: )
      if response_ok?(response: response)
        data_parser(body: response.body.force_encoding("UTF-8"))
      else
        Rails.logger.warn "No result for the searched school name " \
                          "\"#{searched_school_name}\" in the " \
                          "department \"#{department}\""
      end
    end

    def sanitize(string)
      string.gsub(/[\n\r]/, ' ')
            .gsub(/\s+/, ' ')
            .strip
    end

    def data_parser(body:)
      result = nil
      klass = ".etablissement.etablissement--extra_search_result.etablissement--search__item"
      Nokogiri::HTML5.parse(body).css(klass).each do |article|
        next unless article['about'].to_s.include?(code_uai)

        result = {
          phone: article.css(".establishment--search_item__contact a")[0]['href'][4..-1],
          address: article.css(".establishment--search_item__content .establishment--address-line")[0].text.strip,
          email: article.css(".establishment--search_item__content .establishment--search_item__address a")[0]['href'][7..-1]
        }
        break
      end
      result
    end

    def response_ok?(response:)
      return false if response.nil?

      response.code.to_i.between?(200, 299)
    end
  end
end
