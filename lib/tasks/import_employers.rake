# frozen_string_literal: true
require 'open-uri'

desc 'Import and create new employers'
task :import_and_create_employers, [:csv_uri] => :environment do |t, args|
  created_count = 0
  errors_count = 0

  csv_data = open(args[:csv_uri]).read

  CSV.parse(csv_data, encoding: "utf-8", quote_char: ",", headers: :first_row).each do |row|
    first_name = row[0]
    last_name = row[1]
    password = row[2]
    email = row[3]
    
    employer = Users::Employer.where(email: email).first

    unless employer
      employer = Users::Employer.new(
        first_name: first_name,
        last_name: last_name,
        email: email,
        password: password,
        accept_terms: true
      )
      
      if employer.save
        puts "employer created : ##{employer.id}"
        created_count += 1
      else
        puts "ERROR : "
        p employer.errors.messages
        errors_count += 1
      end
    end
      
    puts "---------"
  end

  puts "---------"
  puts "---END---"
  puts "---------"
  puts "#{errors_count} errors."
  puts "#{created_count} employers created !"
end
