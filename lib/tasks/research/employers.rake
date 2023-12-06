
namespace :research do
  desc 'Migrate group_id to ministry_group table'
  task :employers_without_applications, [] => :environment do |task, args|
    require 'fileutils'
    require 'pretty_console'
    require 'csv'
    PrettyConsole.announce_task(task) do

      # targeted_fields = %w[id employeur no_offre secteur ville(code_postal) nb_places_offertes lien environnement]
      targeted_fields = "id employeur, nombre de semaines, dates, employeur,no offre, secteur, ville(code_postal), nb de places offerte, lien, environnement"
      site = "https://www.monstagedetroisieme.fr"
      CSV.open("tmp/employers_without_applications.csv", "w",force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
        csv << targeted_fields.split(',').map(&:strip)
        employer_ids = Users::Employer.kept
                                      .joins(:internship_offers)
                                      .where('internship_offers.id NOT IN (SELECT internship_offer_id FROM internship_applications)')
                                      .where(internship_offers: {discarded_at: nil})
                                      .to_a
                                      .uniq
                                      .pluck(:id)

        offer_details = InternshipOffer.kept
                                       .published
                                       .joins(:sector)
                                       .includes(:sector)
                                       .order(:employer_id)
                                       .where(employer_id: employer_ids)
                                       .to_a

        offer_details.each do |offer|
          weeks = offer.weeks
          csv << [ offer.employer_id,
                   weeks.size,
                   Presenters::WeekList.new(weeks: weeks).split_weeks_in_trunks.map(&:to_range_as_str),
                   offer.employer_name,
                   offer.id,
                   offer.sector.name,
                   "#{offer.city} (#{offer.zipcode})",
                   offer.max_candidates,
                   "#{site}/offres-de-stage/#{offer.id}",
                   "production"]
        end
      end
    end
  end
end