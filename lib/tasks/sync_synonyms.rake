require 'fileutils'
# usage : rails internship_offers:setup_synonyms

namespace :internship_offer_keywords do
  # Step 1- as god in production, you can retrieve csv file of InternshipOfferKeyword
  # Step 1 is for local machine
  desc 'Import csv production keywords into dev db'
  task :import_csv_file, [] => :environment do
    require 'csv'
    csv_file = 'db/data_imports/latest_keywords_copy.csv'
    SEPARATOR = ','

    csv = CSV.read(
      csv_file,
      col_sep: SEPARATOR,
      quote_char: '"',
      encoding: 'bom|utf-8',
      headers: :first_row,
      liberal_parsing: true
    )

    csv.each do |row|
      data = {
          word: row[1],
          ndoc: row[2],
          nentry: row[3],
          searchable: row[4],
          word_nature: row[5]
        }
      InternshipOfferKeyword.where(word: row[1]).first_or_create(data)
    end
    say_in_green 'task is finished'
  end

  # step 2
  # Step 2 is for local machine
  desc 'Retrieving data from external synonyms dictionnary for db update'
  task :get_synonyms, [] => :environment do
    InternshipOfferKeyword.where(searchable: true).each do |keyword|
      synonyms = Services::SyncCnrtlSynonym.new(word: keyword.word).synonyms
      InternshipOfferKeyword.where(id: keyword.id)
                            .update(synonyms: total_length_limited(synonyms, 199))

    end

    say_in_green 'task is finished'
  end

  # step 3
  # Step 3 is for local machine
  # The generated file will setup production db
  desc 'updating csv file by adding synonyms in a new file'
  task :add_synonyms_to_csv, [] => :environment do
    require 'csv'
    csv_file_in = 'db/data_imports/latest_keywords_copy.csv'
    csv_file_out = 'db/data_imports/latest_keywords_with_synonyms.csv'
    separator = ','
    CSV.open( csv_file_out, "wb", force_quotes: true, quote_char: '"', col_sep: separator ) do |csv_out|
      CSV.open( csv_file_in, "r", force_quotes: true, quote_char: '"', col_sep: separator ) do |csv_in|
        csv_in.each_with_index do |row, index|
          if row[6].nil? && index.zero?
            synonyms = 'Synonyms'
          elsif row[6]
            synonyms = row[6]
          else
            keyword = InternshipOfferKeyword.find_by(word: row[1])
            if keyword.nil?
              puts "Error with word : #{row[1]}"
              break
            else
              synonyms = keyword&.synonyms || ''
            end
          end
          csv_out << row + [synonyms]
        end
      end
    end
    say_in_green 'task is finished'
  end

  # step 4
  # Step 4 is for production and local
  desc 'updating db with a synonyms file'
  task :update_db_with_synonyms, [] => :environment do
    require 'csv'
    csv_file = 'db/data_imports/latest_keywords_with_synonyms.csv'
    separator = ','
    time_measure(label: 'general_treatment') do
      CSV.open(
        csv_file,
        "r",
        force_quotes: true,
        quote_char: '"',
        col_sep: separator
      ) do |csv|
        upsert_data = []
        time_measure(label: 'csv browsing') do
          csv.each_with_index do |row, index|
            next if index.zero?

            keyword = InternshipOfferKeyword.find_by(word: row[1])
            if keyword.nil?
              say_in_red "Error with word : #{row[1]}"
            else
              upsert_data << {
                id: keyword.id,
                word: row[1],
                ndoc: row[2],
                nentry: row[3],
                searchable: row[4],
                word_nature: row[5],
                synonyms: row[6] || ''
              }
            end
          end
        end
        time_measure(label: 'upsert time') do
          InternshipOfferKeyword.upsert_all(upsert_data, unique_by: %i[word])
        end
      end
    end
    say_in_green 'task is finished'
  end

  # step 5
  # Step 5 is for production and local
  desc 'generating a thesaurus file from db'
  task :thesaurus_file_generation, [] => :environment do
    InternshipOfferKeyword.update_thesaurus_file
  end

  # Utils
  #=========
  def total_length_limited(words, length)
    separator = ";"
    words_joined = ''
    words.each do |word|
      initial_word = words_joined
      words_joined += "#{separator}#{word}"
      return initial_word[1..-1] if words_joined.length >= length
    end
    words_joined[1..-1]
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end

  def say_in_red(str)
    puts "\e[31m=====> #{str} <=====\e[0m"
  end

  def time_measure(label: nil)
    t_start = Time.now
    yield
    t_end = Time.now
    say_in_green "#{label} performed in : #{(t_end.to_f-t_start.to_f)}"
  end

end
