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
def populate_operators
  ["Clubs régionaux  d'entreprises pour l'insertion (CREPI)", "Dégun sans stage (Ecole centrale de Marseille)", "Fondation Agir contre l'Exclusion (FACE)", "JOB IRL", "Les entreprises pour la cité (LEPC)", "Un stage et après !", "Tous en stage", "Viens voir mon taf"].each do |operator|
    User.find_or_create_by(operator_name: operator)
  end
end

def populate_schools
  CSV.foreach(Rails.root.join('db/college-rep-plus.csv'), {headers: { col_sep: ','}}) do |row, i|
    puts row["Département"].inspect
    puts row["Commune"].inspect
    puts row["Code UAI"].inspect
    puts row["ETABLISSEMENT"].inspect
    puts i.inspect
  end
end

populate_week_reference
populate_operators
populate_schools
