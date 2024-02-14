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
        type: InternshipOffers::WeeklyFramed, 
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
    weeks = row[11].split('-').map { |w| Week.find_by(number: w.to_i, year: Date.current.year).id }
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
        type: InternshipOffers::WeeklyFramed, 
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

desc 'Import new offers 4 steps'
task :import_offers_in_4_steps, [:csv_uri] => :environment do |t, args|
  
  puts "---------"
  puts args[:csv_uri]
  puts "---------"

  created_count = 0
  errors = []
  csv_data =  URI.open(args[:csv_uri]).read
  
  # Column 0 : Company name
  # Column 1 : SIRET
  # Column 2 : Employer name
  # Column 3 : Employer first name
  # Column 4 : Employer email
  # Column 5 : Employer phone
  # Column 6 : Employer description
  # Column 7 : Private or Public
  # Column 8 : Street
  # Column 9 : Zipcode
  # Column 10 : City
  # Column 11 : Offer Title
  # Column 12 : Offer Description
  # Column 13 : Offer Sector
  # Column 14 : Offer Activities
  # Column 15 : Offer Max candidates
  # Column 16 : Offer students per group
  # Column 17 : Offer weeks
  # Column 18 : Offer weekly hours start
  # Column 19 : Offer weekly hours end
  # Column 20 : Offer lunch break

  created_employers = []

  CSV.parse(csv_data).each_with_index do |row, i|
    next if i < 2

    puts row 

    employer_name = row[0]
    siret = row[1]
    email = row[4]
    employer = Users::Employer.where(email: email).first
    unless employer
      password = Devise.friendly_token.first(8)

      employer = Users::Employer.create(
        email: email,
        first_name: row[3],
        last_name: row[2],
        password: password
      )

      employer.update(
        confirmed_at: Time.current,
      )


      if employer.current_area_id.nil?
        a = InternshipOfferArea.create(
          employer_id: employer.id,
          employer_type: "User",
          name: "Mon espace"
        )
        employer.update(current_area_id: a.id)
      end

      created_employers << {email: email, password: password}
    end

    contact_phone = row[5]
    is_public = row[7] == "Public" ? true : false
    street = row[8]
    zipcode = row[9]
    city = row[10]
    title = row[11]
    description = row[12] ? row[12][0..480] : 'Découverte du métier'
    sector_id = Sector.where(name: row[13]).first.try(:id) || Sector.first.id
    

    max_candidates = row[15] || 1
    max_students_per_group = row[16] || 1
    weeks = row[17].split(',').map { |w| Week.find_by(number: w.to_i, year: Date.current.year) }
    weekly_hours = [row[18], row[19]]
    lunch_break = row[20]
    
    address = "#{street} #{zipcode} #{city}"
    coordinates = Geocoder.search(address).first.try(:coordinates)
    coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)
    coordinates ||= Geocoder.search(city).first.try(:coordinates)

    if address.present? && coordinates 
      # Step 1
      organisation = Organisation.new(
        employer_name: employer_name,
        street: street,
        zipcode: zipcode,
        city: city,
        is_public: is_public,
        coordinates: {latitude: coordinates[0], longitude: coordinates[1]},
        employer: employer
      )

      if organisation.save
        puts "organisation created : ##{organisation.id}"

        # Step 2
        internship_offer_info = InternshipOfferInfo.new(
          title: title,
          description_rich_text: "<div>#{description}</div>",
          sector_id: sector_id,
          max_candidates: max_candidates,
          employer: employer
        )

        if internship_offer_info.save
          puts "internship_offer_info created : ##{internship_offer_info.id}"
          
          # Step 3
          hosting_info = HostingInfo.new(
            weeks: weeks,
            max_candidates: max_candidates,
            max_students_per_group: max_students_per_group,
            employer: employer
          )

          if hosting_info.save
            puts "hosting_info created : ##{hosting_info.id}"

            # Step 4
            practical_info = PracticalInfo.new(
              street: street,
              zipcode: zipcode,
              city: city,
              coordinates: {latitude: coordinates[0], longitude: coordinates[1]},
              weekly_hours: ["9:00", "17:00"],
              employer: employer,
              contact_phone: contact_phone
            )

            if practical_info.save
              puts "practical_info created : ##{practical_info.id}"


              Builders::InternshipOfferBuilder.new(user: employer, context: :web).create_from_stepper(
                internship_offer_info: internship_offer_info,
                hosting_info: hosting_info,
                practical_info: practical_info,
                organisation: organisation
              ) do |on|
                on.success do |offer|
                  offer.publish!
                  puts "offer created : ##{offer.id}"
                  puts "offer published : ##{offer.contact_phone}"
                  created_count += 1
                end
                on.failure do |failed_offer|
                  puts "ERROR Internship Offer : "
               
                  p failed_offer.errors.messages
                  errors << [i, email, failed_offer.errors.messages]
                end
              end
            else
              puts "ERROR practical_info : "
              p practical_info.errors.messages
              errors << [i, email, practical_info.errors.messages]
            end
          else
            puts "ERROR hosting_info : "
            p hosting_info.errors.messages
            errors << [i, email, hosting_info.errors.messages]
          end
        else
          puts "ERROR internship_offer_info : "
          p internship_offer_info.errors.messages
          errors << [i, email, internship_offer_info.errors.messages]
        end
      else
        puts "ERROR organisation : "
        p organisation.errors.messages
        errors << [i, email, organisation.errors.messages]
      end

    else
      puts "ERROR : address or employer not found : #{address}"
      errors << title
    end
    puts "---------"
  end

  puts "---------"
  puts "---END---"
  puts "---------"
  puts "#{errors.count} errors."
  if errors.count > 0
    puts "################"
    puts "Errors :"
    errors.each do |error|
      puts "Ligne #{error[0]} (#{error[1]}) - #{error[2]}"
    end
    puts "################"
  end
  if created_employers.count > 0
    puts "################"
    puts "New employers created :"
    created_employers.each do |employer|
      puts "#{employer[:email]} - #{employer[:password]}"
    end
    puts "################"
  end
  puts "#{created_count} offers created !"
end
