# frozen_string_literal: true
require 'open-uri'

desc 'Import new offers'
task :import_weekly_framed_offers, [:employer_id, :csv_uri] => :environment do |t, args|
  weeks = Week.selectable_from_now_until_end_of_school_year.map(&:id)
  employer = Users::Employer.find(args[:employer_id])
  created_count = 0
  errors_count = 0

  csv_data = open(args[:csv_uri]).read

  CSV.parse(csv_data).each do |row|
    employer_name = row[0]
    street = row[2]
    zipcode = row[3]
    city = row[4]
    title = row[5]
    description = row[6]
    sector = row[7]
    max_candidates = row[10]
    tutor_name = row[13]
    tutor_email = row[14]
    tutor_phone = row[15]
    
    address = "#{street} #{zipcode} #{city}"
    coordinates = Geocoder.search(address).first.try(:coordinates)
    coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)

    if coordinates 
      offer = InternshipOffer.new(
        employer_name: employer_name,
        is_public: false, 
        street: street,
        zipcode: zipcode,
        city: city,
        title: title,
        sector_id: sector,
        description_rich_text: "<div>#{description}</div>",
        max_candidates: max_candidates, 
        tutor_name: tutor_name,
        tutor_email: tutor_email,
        tutor_phone: tutor_phone,
        week_ids: weeks, 
        weekly_hours: ["9:00", "17:00"],
        coordinates: {latitude: coordinates[0], longitude: coordinates[1]},
        employer: employer
      )
      
      if offer.save
        puts "offer created : ##{offer.id}"
        created_count += 1
      else
        puts "ERROR : "
        p offer.errors.messages
        errors_count += 1
      end
    else
      puts "ERROR : address not found : #{address}"
      errors_count += 1
    end
    puts "---------"
  end

  puts "---------"
  puts "---END---"
  puts "---------"
  puts "#{errors_count} errors."
  puts "#{created_count} offers created !"
end

desc 'Import new offers'
task :import_weekly_framed_offers_with_employers_already_created, [:csv_uri] => :environment do |t, args|
  weeks = Week.selectable_from_now_until_end_of_school_year.map(&:id)
  created_count = 0
  errors_count = 0
  
  csv_data = open(args[:csv_uri]).read
  
  CSV.parse(csv_data).each do |row|
    employer_name = row[0]
    street = row[2]
    zipcode = row[3]
    city = row[4]
    title = row[5]
    description = row[6]
    sector = row[7]
    max_candidates = row[10]
    tutor_name = row[13]
    tutor_email = row[14]
    tutor_phone = row[15]
    
    address = "#{street} #{zipcode} #{city}"
    coordinates = Geocoder.search(address).first.try(:coordinates)
    coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)
    
    employer = Users::Employer.where(email: tutor_email).first

    if coordinates && employer
      offer = InternshipOffer.new(
        employer_name: employer_name,
        is_public: false, 
        street: street,
        zipcode: zipcode,
        city: city, 
        title: title,
        sector_id: sector,
        description_rich_text: "<div>#{description}</div>",
        max_candidates: max_candidates, 
        tutor_name: tutor_name,
        tutor_email: tutor_email,
        tutor_phone: tutor_phone,
        week_ids: weeks, 
        weekly_hours: ["9:00", "17:00"],
        coordinates: {latitude: coordinates[0], longitude: coordinates[1]},
        employer: employer
      )
      
      if offer.save
        puts "offer created : ##{offer.id}"
        created_count += 1
      else
        puts "ERROR : "
        p offer.errors.messages
        errors_count += 1
      end
    else
      puts "ERROR : address or employer not found : #{address} / #{tutor_email}"
      errors_count += 1
    end
    puts "---------"
  end

  puts "---------"
  puts "---END---"
  puts "---------"
  puts "#{errors_count} errors."
  puts "#{created_count} offers created !"
end
