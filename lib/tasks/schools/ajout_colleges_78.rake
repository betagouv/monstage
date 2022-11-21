namespace :schools do
   desc "15/11/2022 Ajout des collèges du 78 par dérogation"
   task :ajout_colleges_78 => :environment do
      CSV.foreach(Rails.root.join('db/data_imports/Colleges_par_derogation_78.csv'), headers: true, col_sep: ';').each do |row|
         code_uai = row[0].upcase
         name = row[1]
         street = row[2]
         zipcode = row[3]
         city = row[4]
         kind = if row[5] == "REP"
                  "rep"
               elsif row[5] == "REP+"
                  "rep_plus"
               else
                  "qpv"
               end

         school = School.find_by(code_uai: code_uai)

         if school.present?
            puts "Le collège #{school.name} existe déjà"
         else
            address = "#{street} #{zipcode} #{city}"
            coordinates = Geocoder.search(address).first.try(:coordinates)
            coordinates ||= Geocoder.search("#{zipcode} #{city}").first.try(:coordinates)

            if coordinates
               school = School.create(
                  name: name,
                  street: street,
                  zipcode: zipcode,
                  city: city,
                  code_uai: code_uai,
                  kind: kind,
                  coordinates: {latitude: coordinates[0], longitude: coordinates[1]}
               )

               puts "Collège ajouté #{code_uai}"
            else
               puts "ERROR : coordonnées GPS non trouvées pour l'adresse " + address
            end
         end
      end
   end
end