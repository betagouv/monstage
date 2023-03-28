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

desc 'Evaluate employers count with approved application under conditions'
task employers_with_potential_agreeements: :environment do
  class_rooms          = ClassRoom.arel_table
  offers               = InternshipOffer.arel_table
  department_str_array = School.experimented_school_departments
  offer_ids = InternshipApplications::WeeklyFramed.joins( :week , student: {class_room: :school})
                                                  .approved
                                                  .merge(School.from_departments(department_str_array: department_str_array))
                                                  .merge(Week.in_the_future)
                                                  .includes(:internship_offer)
                                                  .to_a
                                                  .map(&:internship_offer)
                                                  .map(&:id)
                                                  .uniq
    if offer_ids.empty?
    puts "no count"
  else
    emails = InternshipOffer.where(offers[:id].in(offer_ids))
                                           .includes(:employer)
                                           .map { |offer| offer.employer.email }
                                           .uniq

    puts "Results: #{emails}"
  end
end