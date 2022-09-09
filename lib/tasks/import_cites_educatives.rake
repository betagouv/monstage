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
  # Data correction
  wrong_uai = School.find_by_code_uai('065 0740B')
  wrong_uai.update(code_uai: '0650740B') unless wrong_uai.nil?

  # Run the task
  data_file_path = Rails.root.join('db/data_imports/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv')
  schools = {}
  CSV.open(data_file_path, headers: { col_sep: ';' }).each do |row|
    fields = row.to_s.split(';')
    code_uai = fields[0]
    street = fields[5]
    if street.blank?
      puts("Adresse manquante pour #{code_uai}")
    else
      schools[code_uai] = street
    end
  end
  puts "Les adresses manquantes ne sont pas forcément fatales car le fichier " \
       "de départ correspond à toutes écoles et collèges de France, et pas" \
       " nécessairement des collèges REP ou REP+ ."

  # updating db schools
  counter_ok = 0
  counter_ko = 0
  School.where(street: nil).each do |school|
    street = schools[school.code_uai]
    if street.nil?
      counter_ko += 1
      PrettyConsole.puts_in_purple("KO : #{school.code_uai} : #{school.name} | #{school.city} - #{school.zipcode}")
    else
      counter_ok += 1
      print('.')
    end

    raise 'boom' unless school.update(street:street)
  end

  puts('')
  PrettyConsole.say_in_heavy_white('Resultats')
  PrettyConsole.puts_in_green("OK: #{counter_ok}")
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


