require 'pretty_console'

namespace :update_internship_offers do
  desc 'Copy practical_info.address to internship_offer.address'
  task :update_addresses => :environment do |task|
    PrettyConsole.puts_with_white_background "Starting task : #{task.name}"
    # 
    InternshipOffer.kept.find_in_batches do |batch|
      sleep(3)
      batch.each do |offer|
        next if offer.practical_info.blank?
        offer.update(street: offer.practical_info.street)
        offer.update(zipcode: offer.practical_info.zipcode)
        offer.update(city: offer.practical_info.city)
        offer.update(coordinates: offer.practical_info.coordinates)
        print '.'
      end
    end
    puts ''
    PrettyConsole.say_in_green 'Task completed'
  end
end


