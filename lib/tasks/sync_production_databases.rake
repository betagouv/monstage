# called by clever cloud cron evry 10 minutes
desc 'To be scheduled in a cron every 10 minutes'
task sync_production_databases: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), sync production databases")

  SyncProductionDatabasesJob.perform_later
end
