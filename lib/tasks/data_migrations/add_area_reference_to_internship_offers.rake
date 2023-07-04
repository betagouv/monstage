
namespace :data_migrations do
  desc 'create internship offer areas for each employer'
  task add_area_reference_to_internship_offer: :environment do

  InternshipOffers::WeeklyFramed.kept.each do |offer|
      employer = User.find(offer.employer_id)
      offer.update(internship_offer_area_id: employer.internship_offer_areas.first.id)
    end
  end
end