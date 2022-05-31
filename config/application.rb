require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Monstage
  class Application < Rails::Application
    config.time_zone = 'Paris'
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_support.executor_around_test_case = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.active_job.queue_adapter = :sidekiq

    config.public_file_server.enabled = true

    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"

    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag }

    config.active_record.schema_format = :sql

    config.middleware.use Rack::Deflater

    config.exceptions_app = self.routes
  end
end
