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

  desc 'scrapping afdas'
  task :scrapping_afdas_data, [] => :environment do
    require 'csv'
    PrettyConsole.announce_task(name: "Starting extracting unml data from its website") do
      url_ends = []
      url_to_parse = 'https://www.afdas.com/en-region.html'
      response = HTTParty.get url_to_parse
      document = Nokogiri::HTML(response.body)
      boxes = document.css('.container .row')
      boxes.each do |box|
        url_ends << box.xpath('//p/a/@href')
      end
      url_ends = url_ends.flatten.uniq
      puts url_ends
      CSV.open("tmp/afdas_scrapping.csv", "w",force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
        url_ends.each do |url_end|
          url =  "https://www.afdas.com#{url_end}"
          response = HTTParty.get url
          document = Nokogiri::HTML(response.body)
          sub_boxes = document.css('.article .contact')
          sub_boxes.each do |sub_box|
            title = sub_box.css('h2').text.strip
            cols = sub_box.css('.col-lg-6')
            ps = cols.first.css('p')
            address = ps.first.text.strip
            email = ps[1].css('a').text.strip.gsub('(@)', '@')
            phone = cols[1].css('p strong').text.strip 
            csv << [url_end, title, address, email, phone]
          end
        end
      end
    end
  end
end
