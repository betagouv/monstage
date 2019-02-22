FIRST_YEAR = 2019
LAST_YEAR = 2050

FIRST_WEEK = 1
LAST_WEEK = 53 # A 53 week exisits! https://fr.wikipedia.org/wiki/Semaine_53

def populate_week_reference
  FIRST_YEAR.upto(LAST_YEAR) do |year|
    FIRST_WEEK.upto(LAST_WEEK) do |week| # number of the week
      begin
        if week == LAST_WEEK
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

populate_week_reference

def populate_operators
  ["Clubs régionaux  d'entreprises pour l'insertion (CREPI)", "Dégun sans stage (Ecole centrale de Marseille)", "Fondation Agir contre l'Exclusion (FACE)", "JOB IRL", "Les entreprises pour la cité (LEPC)", "Un stage et après !", "Tous en stage", "Viens voir mon taf"].each do |operator|
    User.find_or_create_by(operator_name: operator)
  end
end

populate_operators
