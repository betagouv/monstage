require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = {
    namespace: Rails.env
  }
end

