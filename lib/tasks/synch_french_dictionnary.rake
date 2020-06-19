# frozen_string_literal: true

# usage : rails internship_offers:extract_keyword

namespace :internship_offers do
  desc 'Export monstage DB users emails to Sendgrid contact DB'
  task :extract_keyword, [] => :environment do
    time_start = Time.now
    file_name = 'tmp/extracts/2020_06_18-keywords.dump'
    file_name_output = 'tmp/extracts/2020_06_18-keywords_json.dump'

    # remove_all_data(file_name, time_start)

    say_in_green 'using dictionnary'
    counter = 0
    175.times do |n|
      puts ''
      puts "page(n) : #{n}"
      puts '-----------'
      InternshipOfferKeyword.all.first(100 * n).last(100).each do |keyword|
        next unless keyword.searchable
        next if keyword.word_nature

        InternshipOfferKeyword.qualify_single_word(keyword: keyword)
        sleep 0.03 + (rand(10).to_f / 100)
      end
      elapsed_time(time_start)
      sleep(rand(2..4))

      counter += 1
      break if counter > 200
    end
    # ==================================
    say_in_green 'dictionnary task is finished, serializing now'
    elapsed_time(time_start)

    File.open(file_name_output, 'w') do |file|
      file_content = InternshipOfferKeyword.select(:id, :searchable, :word_nature)
                                           .to_json
      file.write file_content
    rescue IOError => e
      puts '================'
      puts "error : #{e}"
      puts '================'
    ensure
      file&.close
    end

    say_in_green 'task is finished'
  end

  def remove_all_data(file_name, time_start)
    # ==================================
    say_in_green 'removing all data from InternshipOfferKeyword'
    InternshipOfferKeyword.delete_all if InternshipOfferKeyword.all.count.positive?
    elapsed_time(time_start)
    # ==================================

    say_in_green 'Starting populating keyword table'
    file_data = File.open(file_name)
    arr_data = file_data.readlines.map(&:chomp)

    arr_data.each do |line|
      word_hash = line_to_json line
      InternshipOfferKeyword.create(
        word: word_hash['word'],
        ndoc: 0,
        nentry: 0,
        searchable: true
      )
    end
    elapsed_time(time_start)
    # ==================================
  end

  def line_to_json(line)
    JSON.parse line.gsub('=>', ':')
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end

  def elapsed_time(time_start)
    puts '================'
    puts "Time.now - time_start : #{Time.now - time_start}"
    puts '================'
  end

  desc 'import monstage DB users emails to Sendgrid contact DB'
  task :load_keyword_data, [] => :environment do
    time_start = Time.now
    file_name = 'tmp/extracts/2020_06_18-keywords_json.dump'

    # --------------------------------
    # Unfinished business TODO
    # --------------------------------
  end
end

# InternshipOfferKeyword.all.each do |keyword|
#   file.write Marshal.dump(keyword).force_encoding('ISO-8859-1').encode('UTF-8')
# end
