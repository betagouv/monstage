
require 'pretty_console'

# There's a business gotcha: the given email should NOT be a shared email or a generic one!

namespace :migrations do
  desc 'Migrate location from organisation to internship_offer_info'
  task :set_internship_offer_info_location_from_organisation, [:identity] => :environment do |t, args|
    # Use it this way:
    # ======================================
    #   bundle exec rake "migrations:set_internship_offer_info_location_from_organisation"
    # ======================================
    InternshipOfferInfo.where(coordinates: nil).find_each do |internship_offer_info|
      internship_offer = internship_offer_info.internship_offer
      organisation = internship_offer&.organisation
      if(organisation.nil?)
        puts '================'
        puts "missing organisation for  : #{internship_offer.id }"
        puts '================'
        puts ''
      next if organisation.nil?

      internship_offer_info.employer_name ||= organisation.employer_name
      internship_offer_info.street        ||= organisation.street
      internship_offer_info.zipcode       ||= organisation.zipcode
      internship_offer_info.city          ||= organisation.city
      internship_offer_info.coordinates   ||= organisation.coordinates
      
      internship_offer_info.save!
    end
  end
end