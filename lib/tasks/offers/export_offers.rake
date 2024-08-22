require 'fileutils'
require 'pretty_console'
# usage : rails users:extract_email_data_csv

namespace :offers do
  desc 'Export offers et requests by week'
  task :extract_offers_success_csv, [] => :environment do
    PrettyConsole.say_in_green 'Starting extracting offers and applications metadata'

    require 'csv'

    targeted_fields = %i[semaine offres sièges candidatures écoles ratio_offres_ecoles]
    CSV.open('tmp/export_week_activity.csv', 'w', force_quotes: true, quote_char: '"', col_sep: ',') do |csv|
      csv << [].concat(targeted_fields, ['environment'])

      fetch_weeks.each do |week|
        weekly_framed = InternshipOffers::WeeklyFramed.kept
                                                      .published
                                                      .joins(:internship_offer_weeks)
                                                      .where({ internship_offer_weeks: { week_id: week.id } })
        api = InternshipOffers::Api.kept
                                   .published
                                   .joins(:internship_offer_weeks)
                                   .where(internship_offer_weeks: { week_id: week.id })
        seats = weekly_framed.pluck(:max_candidates)
        api_seats = api.pluck(:max_candidates)
        applications = InternshipApplications::WeeklyFramed.joins(:internship_offer_week)
                                                           .where(internship_offer_week: { week_id: week.id })
        schools = School.joins(:school_internship_weeks).where(school_internship_weeks: { week_id: week.id })
        offers = weekly_framed.count + api.count
        ratio = schools.count.zero? ? 'NA' : offers / schools.count
        csv << [
          "#{week.beginning_of_week} - #{week.end_of_week}",
          offers,
          seats.sum + api_seats.sum,
          applications.count,
          schools.count,
          ratio,
          'production'
        ]
      end
    end
    PrettyConsole.say_in_green 'task is finished'
  end

  def fetch_weeks
    Week.selectable_for_school_year(school_year: SchoolYear::Current.new)
  end

  def text_normalization(text)
    ActionView::Base.full_sanitizer.sanitize(text.squish.gsub("'", ' '))
  end

  def normalized_offer_hash(offer, index)
    {
      employer_name: offer.employer_name,
      title: offer.title,
      'sectors - sector_id → name': offer.sector.name,
      id: offer.id,
      aasm_state: offer.aasm_state,
      discarded_at: offer.discarded_at,
      description: offer.description,
      index:,
      norma: text_normalization(offer.description)
    }
  end

  desc 'Export offers for IA purpose . Json format'
  task :one_year_json_extract, [] => :environment do
    # sample:
    # [{
    #   "employer_name": "CENTRE HOSPITALIER DE VALENCIENNES",
    #   "title": "Métiers de la santé, Métiers de l'administration hospitalière, Métiers de la logistique",
    #   "sectors - sector_id → name": "Fonction publique",
    #   "id": 33271,
    #   "aasm_state": "published",
    #   "discarded_at": null,
    #   "description": "\n  Stage d'observation et de découverte des différents métiers du milieu Hospitalier ",
    #   "index": 3,
    #   "norma": "Stage d' observation et de découverte des différents métiers du milieu Hospitalier"
    #  }]
    PrettyConsole.say_in_green 'Starting extracting offers'

    offers = InternshipOffers::WeeklyFramed.kept.published.where('updated_at > ?', 1.year.ago)
    api = InternshipOffers::Api.kept.published.where('updated_at > ?', 1.year.ago)

    data = offers.map.with_index { |offer, index| normalized_offer_hash(offer, index) }
    api_data = api.map.with_index { |offer, index| normalized_offer_hash(offer, index) }
    data = data.concat(api_data)

    File.open('tmp/one_year_json_extract.json', 'w') do |f|
      f.write(data.to_json)
    end

    PrettyConsole.say_in_green 'json offers extraction task is finished'
  end
end
