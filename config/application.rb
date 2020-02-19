# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Monstage
  class Application < Rails::Application
    config.time_zone = 'Paris'
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.autoloader = :zeitwerk

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.active_job.queue_adapter = :delayed_job

    config.public_file_server.enabled = true

    config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'

    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    config.middleware.use Rack::Deflater
  end
end
