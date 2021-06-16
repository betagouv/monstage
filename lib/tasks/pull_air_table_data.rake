# call by clever cloud cron daily at 9am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in cron at midnight to pull air table data'
task pull_air_table_data: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), pull_air_table_data")
  Airtable::BaseSynchronizer.new.pull_all
end
