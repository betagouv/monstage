require 'pretty_console'
# call by clever cloud cron daily at 9am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in cron a 9pm to remind employer to manage their internship applications'
task internship_application_reminders: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), internship_application_reminders")
  if [Date.today.monday?, Date.today.thursday?].any?
    Triggers::InternshipApplicationReminder.new.enqueue_all
  end
end

desc 'To be scheduled in cron a 9pm to remind employer to manage their internship applications'
task student_single_application_reminders: :environment do
  PrettyConsole.announce_task :student_single_application_reminders do
    Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), student_single_application_reminders")
    Triggers::SingleApplicationReminder.new.enqueue_all
  end
end

desc 'To be scheduled in cron a 9pm to remind student to manage their accepted by employer internship applications'
task students_internship_application_reminders: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), internship_application_reminders")
  Triggers::StudentAcceptedInternshipApplicationReminder.new.enqueue_all
end

# call by clever cloud cron daily at 9am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in cron a 9pm to remind employer to manage their internship applications'
task school_missing_weeks_reminders: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), school_missing_weeks_reminders")
  if Date.today.monday?
    Triggers::SchoolMissingWeeksReminder.new.enqueue_all
  end
end

desc 'Evaluate employers count with approved application under conditions'
task employers_with_potential_agreeements: :environment do
  class_rooms          = ClassRoom.arel_table
  offers               = InternshipOffer.arel_table
  offer_ids = InternshipApplications::WeeklyFramed.joins( :week , student: {class_room: :school})
                                                  .approved
                                                  .merge(Week.in_the_future)
                                                  .includes(:internship_offer)
                                                  .to_a
                                                  .map(&:internship_offer)
                                                  .map(&:id)
                                                  .uniq
    if offer_ids.empty?
    puts "no count"
  else
    emails = InternshipOffers::WeeklyFramed.where(offers[:id].in(offer_ids))
                                           .includes(:employer)
                                           .map { |offer| offer.employer.email }
                                           .uniq

    puts "Results: #{emails}"
  end
end