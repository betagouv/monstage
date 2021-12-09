# called by clever cloud cron daily at 8am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in a cron at 8am to send kpis of site\'s activity'
task send_weekly_kpis: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), send_me_kpis")
  SendWeeklyKpiEmail.perform_later
end