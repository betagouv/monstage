require 'pretty_console'

def create_organisation_from_internship_offer(offer)
  attributes = {
    employer_name: offer.employer_name,
    employer_website: offer.employer_website,
    coordinates: offer.coordinates,
    street: offer.street,
    zipcode: offer.zipcode,
    city: offer.city,
    is_public: offer.is_public,
    group_id: offer.group_id,
    siret: offer&.siret || '',
    employer_description: offer.employer_description,
    employer_id: offer.employer_id,
    is_paqte: false
  }
  organisation_id = Organisation.find_or_create_by!(attributes).id
  offer.update_columns(organisation_id: organisation_id)
end

namespace :retrofit do
  desc 'missing organisations creation for older kept internship_offers upon internship_offer data'
  task :missing_organisations_creation => :environment do |task|
    PrettyConsole.announce_task(task) do
      ActiveRecord::Base.transaction do
        InternshipOffers::WeeklyFramed.kept
                                      .where(organisation_id: nil)
                                      .each do |offer|
          create_organisation_from_internship_offer(offer)
          print '.'
        end
      end
    end
  end
end