# frozen_string_literal: true
require 'pretty_console.rb'

desc 'Import new cité éducative'
task :import_cites_educatives => :environment do
  CSV.foreach(Rails.root.join('cites_educatives.csv'), headers: { col_sep: ';' }).each do |row|
    name = row[0]
    street = row[1]
    zipcode = row[2]
    city = row[3]

    address = "#{street} #{zipcode} #{city}"
    coordinates = Geocoder.search(address).first.try(:coordinates)
    coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)

    if coordinates
      school = School.create(
        name: name,
        street: street,
        zipcode: zipcode,
        city: city,
        code_uai: row[4],
        coordinates: {latitude: coordinates[0], longitude: coordinates[1]}
      )

      puts "OK #{school.id} - #{school.name}"
    else
      p "ERROR : " + address
    end
  end
end

# Temporary task
desc 'Fix missing school street in production data'
task :fix_missing_school_street => :environment do
  def after_search(places: , school: , search_method:'file')
    counter_ok = 1
    street = ""
    if places.empty? || "#{places&.first&.address["house_number"]} #{places.first.address["road"]}".blank?
      if places&.first&.address&.present?
        street = places.first.address.split(",")[1].strip
        puts ''
        PrettyConsole.puts_in_green( "hope it's ok : #{street} for school ##{school.id} - #{school.code_uai} - #{school.name}")
      else
        counter_ok = 0
        puts''
        PrettyConsole.puts_in_purple("KO | #{search_method} : #{school.code_uai} : #{school.name} | #{school.city} - #{school.zipcode}")
      end
    else
      street = "#{places.first.address["house_number"]} #{places.first.address["road"]}"
    end
    { street: street, counter_ok: counter_ok }
  end

  # Data correction
  wrong_uai = School.find_by_code_uai('065 0740B')
  wrong_uai.update(code_uai: '0650740B') unless wrong_uai.nil?

  # Run the task
  data_file_path = Rails.root.join('db/data_imports/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv')
  listed_schools = {}

  CSV.open(data_file_path, headers: { col_sep: ';' }).each do |row|
    fields = row.to_s.split(';')
    code_uai = fields[0]
    street = fields[5]
    latitude = fields[14]
    longitude = fields[15]
    listed_schools[code_uai] = {
      street: street,
      coordinates: {
        latitude: latitude,
        longitude: longitude
      }
    }
  end


  # updating db schools
  counter_ok = 0
  counter_ko = 0
  ko_by_file_search = 0
  ko_by_name_search = 0
  ok_by_name_search = 0
  missing_uai = 0

  School.where(street: nil).each do |school|
    search_street_by_name_school = nil
    search_result = { street: '', counter_ok: 1 }

    if listed_schools[school.code_uai].present?
      # street might be in file
      street = listed_schools[school.code_uai][:street]
      search_result = { street: street, counter_ok: 1 }
      if search_result[:street].blank?
        # street might be caught by coordinates
        ko_by_file_search += 1
        print 'o'
        latitude  = listed_schools[school.code_uai][:coordinates][:latitude]
        longitude = listed_schools[school.code_uai][:coordinates][:longitude]
        print "x" && next unless latitude.to_f.is_a?(Float) && longitude.to_f.is_a?(Float)
        places = Geocoder.search("#{latitude}, #{longitude}")
        search_result = after_search(places: places, school: school, search_method: 'search by coordinates in file failed ')
        search_street_by_name_school = search_result[:counter_ok].zero? ? school : ''
      end
    else
      missing_uai += 1
      search_street_by_name_school = school
    end
    if search_street_by_name_school.present?
      # Final search by school name
      places = Geocoder.search("Collège #{school.name} #{school.city} #{school.zipcode}")
      search_result = after_search(places: places, school: school, search_method: 'search by name , city and zipcode failed ')
      search_result[:counter_ok].zero? ? ko_by_name_search += 1 : ok_by_name_search +=1
    end
    counter_ok += search_result[:counter_ok]
    if search_result[:counter_ok].zero?
      counter_ko += 1
      next
    end

    street = search_result[:street]
    unless street.blank?
      print('.')
      school.update(street:street)
    end
  end

  puts('')
  PrettyConsole.say_in_heavy_white('Resultats')
  PrettyConsole.puts_in_green("OK: #{counter_ok}")
  PrettyConsole.puts_in_red("note : missing uai in file: #{missing_uai}")
  puts("missing street in reference file : #{ko_by_file_search}")
  puts("streets found by names : #{ok_by_name_search}")
  PrettyConsole.puts_in_red("Kos by name search : #{ko_by_name_search}")
  PrettyConsole.puts_with_red_background("KO: #{counter_ko}")
  puts('')

  # --------- Extra : search for missing coordinates -------

  missing_coordinates_counter = 0
  School.where(coordinates: nil).each do |school|
    missing_coordinates_counter +=1
    PrettyConsole.say_in_red(
      "Missing coordinates for #{school.code_uai} : #{school.name} | #{school.city} - #{school.zipcode}"
    )
  end
  PrettyConsole.say_in_heavy_white(
    "Missing coordinates: #{missing_coordinates_counter}"
  ) unless missing_coordinates_counter.zero?
end


