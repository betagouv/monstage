# call by clever cloud cron daily at 9am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in cron a 9pm to remind employer to manage their internship applications'
task internship_application_reminders: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), internship_application_reminders")
  if [Date.today.monday?, Date.today.thursday?].any?
    Triggers::InternshipApplicationReminder.new.enqueue_all
  end
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
