
desc 'To be scheduled in cron a 8pm to remind employer to manage their internship applications'
task internship_application_reminders: :environment do
  return if [Date.today.monday?, Date.today.thursday?].none?

  Triggers::InternshipApplicationReminder.new.enqueue_all
end
