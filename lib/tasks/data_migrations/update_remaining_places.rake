# nov 12 , 2022
require 'pretty_console'

namespace :data_migrations do
  desc 'After 20221112100533_add_remaining_places_to_internship_offer : update remaining places field in internship offers'
  task :update_remaining_places_count => :environment do |task|
    PrettyConsole.puts_with_white_background "Starting task : #{task.name}"
    ActiveRecord::Base.transaction do
      InternshipOffers::WeeklyFramed.kept.each do |offer|
        offer.update(remaining_places_count: offer.update_remaining_places)
        print '.'
      end
    end

    puts ''
    PrettyConsole.say_in_green 'Task completed'
  end
end


