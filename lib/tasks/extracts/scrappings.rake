require 'fileutils'
require 'pretty_console.rb'
require "watir"

namespace :extracts do
  desc 'scrapping unml'
  task :scrapping_uml_data, [] => :environment do
    require 'csv'
    PrettyConsole.announce_task(name: "Starting extracting unml data from its website") do
      # -------------
      # Following is ok unless data is hidden through js script which is the case here
      # -------------
      # CSV.open("tmp/unml_scrapping.csv", "w",force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
      #   (1..38).to_a.each do |page|
      #     print '.'
      #     url_to_parse = "https://www.unml.info/le-reseau/annuaire/\?pg\=#{page}"

      #     response = HTTParty.get url_to_parse
      #     document = Nokogiri::HTML(response.body)

      #     boxes = document.css('.m-box')
      #     boxes.each do |box|
      #       contents = box.css('p.m-content')
      #       csv << [
      #         box.css('.m-title').text.strip,
      #         contents.first.text.strip.gsub(/\s+/, " ").gsub(/\n+/, " ").strip,
      #         contents[1].text.strip
      #       ]
      #     end
      #   end
      # end
      CSV.open("tmp/unml_scrapping.csv", "w+",force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
        (31..38).to_a.each do |page|
          print '.'
          url_to_parse = "https://www.unml.info/le-reseau/annuaire/\?pg\=#{page}"

          brower = Watir::Browser.new
          brower.goto url_to_parse

          response_body = brower.html
          document = Nokogiri::HTML(response_body)
          boxes = document.css('.m-box')
          boxes.each do |box|
            contents = box.css('p.m-content')
            email = box.css('p.m-content.mb-0 span').text.strip
            csv << [
              box.css('.m-title').text.strip,
              contents.first.text.strip.gsub(/\s+/, " ").gsub(/\n+/, " ").strip,
              contents[1].text.strip,
              email || ''
            ]
          end
        end
      end
    end
  end

end
