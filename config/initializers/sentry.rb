# frozen_string_literal: true

Raven.configure do |config|
  config.dsn = Rails.application.credentials.sentry_dns
  config.environments = %w[review staging production]

  # works async, if it fails, goes in queue
  config.async = lambda { |event| SentryJob.perform_later(event) }

  # record post data, helps with debug
  config.processors -= [Raven::Processor::PostData]

  # by recording posts data, ensure we do not track password fields
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
