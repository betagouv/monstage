# frozen_string_literal: true

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



