require 'pretty_console.rb'

namespace :data_migrations do
  desc 'Add accents and fix typos in group names'
  task fill_daily_hours_in_internship_agreements: :environment do
    PrettyConsole.announce_task(task) do
      InternshipAgreement.kept
                         .where.not(aasm_state: :drafted)
                         .each do |agreement|
        
        daily_hours_reference = agreement.internship_offer.daily_hours
        weekly_hours_reference = agreement.internship_offer.weekly_hours

        if agreement.daily_hours == {} && agreement.weekly_hours.empty? && daily_hours_reference != {}
          print '.'
          agreement.update(daily_hours: daily_hours_reference)
        end

        if agreement.weekly_hours == [] && agreement.daily_hours.blank? && weekly_hours_reference != []
          print 'x'
          agreement.update(weekly_hours: weekly_hours_reference)
        end
      end
    end
  end
end