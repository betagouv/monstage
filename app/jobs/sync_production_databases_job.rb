# frozen_string_literal: true

class SyncProductionDatabasesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("Fetching production database...")
    system("pg_dump -Fc -d #{ENV['PRODUCTION_DATABASE_URI']} > ms3e.dump")

    Rails.logger.info("Updating production copy database...")
    system("pg_restore --verbose --clean --no-acl --no-owner -d '#{ENV['COPY_DATABASE_URI']}' ms3e.dump")

    Rails.logger.info("End")
    system("rm ms3e.dump")
  end
end
