require 'fileutils'
require 'pretty_console.rb'
# usage : rails users:extract_email_data_csv

namespace :offers do
  desc 'Export offers et requests by week'
  task :extract_offers_success_csv, [] => :environment do
    PrettyConsole.say_in_green "Starting extracting offers and applications metadata"

    require 'csv'

    targeted_fields = %i[semaine offres sièges candidatures écoles ratio_offres_ecoles]
    CSV.open("tmp/export_week_activity.csv", "w",force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
      csv << [].concat(targeted_fields, ['environment'])

      fetch_weeks.each do |week|
        weekly_framed = InternshipOffer.kept
                                                      .published
                                                      .joins(:internship_offer_weeks)
                                                      .where({internship_offer_weeks: {week_id: week.id}})
        api = InternshipOffers::Api.kept
                                   .published
                                   .joins(:internship_offer_weeks)
                                   .where(internship_offer_weeks: { week_id: week.id })
        seats = weekly_framed.pluck(:max_candidates)
        api_seats = api.pluck(:max_candidates)
        applications = InternshipApplications::WeeklyFramed.joins(:internship_offer_week)
                                                           .where(internship_offer_week: {week_id: week.id})
        schools = School.joins(:school_internship_weeks).where(school_internship_weeks: {week_id: week.id})
        offers = weekly_framed.count + api.count
        ratio = schools.count.zero? ? 'NA' : offers/schools.count
        csv << [
                "#{week.beginning_of_week} - #{week.end_of_week}",
                offers,
                seats.sum + api_seats.sum,
                applications.count,
                schools.count,
                ratio,
                'production']
      end
    end
    PrettyConsole.say_in_green 'task is finished'
  end

  def fetch_weeks
    Week.selectable_for_school_year(school_year: SchoolYear::Current.new)
  end
end
