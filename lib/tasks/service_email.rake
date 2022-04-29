# called by clever cloud cron daily at 8am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in a cron at 8am to send kpis of site\'s activity'
task send_weekly_kpis: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), send_me_kpis")
  SendWeeklyKpiEmail.perform_later
end

namespace :incident_2022_04_06 do
  desc 'april 13 2022 incident counterparts - applications'
  task applications_retrofit: :environment do
    created_ones = InternshipApplications::WeeklyFramed.where('created_at >= ?', Date.new(2022,4,6)).where('created_at <= ?', DateTime.new(2022,4,13,13,0,0)).where(aasm_state: 'submitted')
    updated_ones = InternshipApplications::WeeklyFramed.where('updated_at >= ?', Date.new(2022,4,6)).where('created_at <= ?', DateTime.new(2022,4,13,13,0,0)).where(aasm_state: 'submitted')
    (created_ones + updated_ones).to_a.uniq.each do |app|
      EmployerMailer.internship_application_submitted_email(internship_application: app).deliver_now
    end
  end

  desc 'april 13 2022 incident counterparts - users'
  task users_retrofit: :environment do
    created_ones = User.where('created_at >= ?', Date.new(2022,4,6)).where('created_at <= ?', DateTime.new(2022,4,13,13,0,0)).where(confirmed_at: nil).where(phone_token: nil)
    created_ones.each do |user|
      next if user.confirmed?

      user.send_confirmation_instructions
    end
  end
end
