class PopulateWeekReference < ActiveRecord::Migration[5.2]
  FIRST_YEAR = 2019
  LAST_YEAR = 2050

  FIRST_WEEK = 1
  # A 53 week exisits! https://fr.wikipedia.org/wiki/Semaine_53
  LAST_WEEK = 53

  def up
    FIRST_YEAR.upto(LAST_YEAR) do |year|
      FIRST_WEEK.upto(LAST_WEEK) do |week| # number of the week
        begin
          if week == LAST_WEEK
            Date.commercial(year, week, 1)
            puts "Special year #{year}, this one have 53 weeks"
          end

          Week.create!(year: year, week: week)
        rescue ArgumentError => e
          puts "no week #{week} for year #{year}"
        end
      end
    end
  end

  def down
    Week.destroy_all
  end
end
