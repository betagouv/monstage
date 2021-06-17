def get_redis_namespace
  return "development-#{Etc.getlogin}".parameterize if Rails.env.development?
  return :production if Rails.env.production?
  return :staging if Rails.env.staging?
  return :test if Rails.env.test?
  return ENV['HEROKU_APP_NAME'] if Rails.env.review?
  return "SIDEKIQ"
end
redis_config = { :namespace => get_redis_namespace }

Sidekiq.configure_server do |config|
 config.redis = redis_config
end

Sidekiq.configure_client do |config|
 config.redis = redis_config
end
