require 'csv'

def populate_week_reference
  first_year = 2019
  last_year = 2050

  first_week = 1
  last_week = 53 # A 53 week exisits! https://fr.wikipedia.org/wiki/Semaine_53

  first_year.upto(last_year) do |year|
    first_week.upto(last_week) do |week| # number of the week
      begin
        if week == last_week
          Date.commercial(year, week, 1)
          puts "Special year #{year}, this one have 53 weeks"
        end

        Week.create!(year: year, number: week)
      rescue ArgumentError
        puts "no week #{week} for year #{year}"
      rescue ActiveRecord::RecordNotUnique
        puts "week #{week} - #{year} already exists"
      end
    end
  end
end

def populate_schools
  CSV.foreach(Rails.root.join('db/college-rep-plus.csv'), {headers: { col_sep: ','}}) do |row, i|
    school = School.find_or_create_by(
      code_uai: row['Code UAI'],
      name: row['ETABLISSEMENT'],
      city: row['Commune'],
      departement_name: row['Département']
    )
    puts "school created: #{school.inspect}"
  end
end

populate_week_reference
populate_schools
