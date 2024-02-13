
require 'pretty_console'

namespace :cleaning do
  desc 'archive teachers without schools or who have not been active for 2 years'
  task :archive_idle_teachers, [] => :environment do |args|
    PrettyConsole.announce_task("Archiving teachers without schools or who have not been active for 2 years") do
      teachers = Users::SchoolManagement.kept.where(role: :teacher)
      user_ids_to_be_anonymized =  teachers.where(school_id: nil).ids
      user_ids_to_be_anonymized += teachers.where('current_sign_in_at < ?', 2.years.ago).ids
      user_ids_to_be_anonymized.to_a.uniq.each do |id|
        UserAnonymizerJob.new.perform(user_id: id)
        PrettyConsole.print_in_yellow "."
      end
    end
  end

  task :archive_idle_employers, [] => :environment do |args|
    PrettyConsole.announce_task("Archiving employers without active offers") do
      reminder_period = 2.weeks
      trigger_date = Date.today - Users::Employer::GRACE_PERIOD + reminder_period
      employer_ids = InternshipOffers::WeeklyFramed.kept
                                                   .where('last_date <= ?', trigger_date)
                                                   .pluck(:employer_id)
                                                   .uniq
      raise 'empty employer list upnormal' if employer_ids.empty?
      filtered_ids = employer_ids.select do |id|
        InternshipOffers::WeeklyFramed.kept
                                      .where(employer_id: id)
                                      .pluck(:last_date)
                                      .max <= trigger_date
      end
      filtered_ids.each do |id|
        EmployerMailer.cleaning_notification_email(id)
                      .deliver_later
        CleaningEmployerJob.set(wait: reminder_period)
                           .perform_later(id)
      end

    end
  end

  task task confidentiality_cleaning: %i[archive_idle_teachers
                                         archive_idle_employers ]
end
