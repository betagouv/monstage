
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
        puts "missing organisation for  : #{internship_offer&.id }"
        puts '================'
        puts ''
        next if organisation.nil?
      end

      internship_offer_info.employer_name ||= organisation.employer_name
      internship_offer_info.street        ||= organisation.street
      internship_offer_info.zipcode       ||= organisation.zipcode
      internship_offer_info.city          ||= organisation.city
      internship_offer_info.coordinates   ||= organisation.coordinates

      internship_offer_info.save!
    end
  end

  desc 'Migrate location modality for internship_offers::api'
  task :set_location_manual_enter_for_api_offers, [:identity] => :environment do |t, args|
    # Use it this way:
    # ======================================
    #   bundle exec rake "migrations:set_location_manual_enter_for_api_offers"
    # ======================================
    InternshipOffers::Api.find_each do |internship_offer|
      internship_offer.location_manual_enter = "from_api"
      if internship_offer.valid?
        internship_offer.save!
      else
        puts '================'
        puts "internship_offer.id : #{internship_offer.id}"
        puts "internship_offer.type : #{internship_offer.type}"
        puts '================'
        puts ''
      end
    end
  end
end