# dual persistence solutions below
# cookie_adapter = Split::Persistence::CookieAdapter
# redis_adapter = Split::Persistence::RedisAdapter.with_config(
#   lookup_by: -> (context) { context.send(:current_user).try(:id) },
#   expire_seconds: 30.days.to_i
# )

Split.configure do |config|
  config.enabled = true
  config.persistence = :cookie
  # or with dual persistence ...
  # config.persistence = Split::Persistence::DualAdapter.with_config(
  #   logged_in: -> (context) { !context.send(:current_user).try(:id).nil? },
  #   logged_in_adapter: redis_adapter,
  #   logged_out_adapter: cookie_adapter
  # )
  config.persistence_cookie_length = 30.days.to_i

  config.db_failover = true # handle Redis errors gracefully
  config.db_failover_on_db_error = -> (error) { Rails.logger.error(error.message) }
  config.allow_multiple_experiments = true
  config.experiments = YAML.load_file "config/ab_experiments.yml"
  # config.persistence = Split::Persistence::SessionAdapter
  #config.start_manually = false ## new test will have to be started manually from the admin panel. default false
  #config.reset_manually = false ## if true, it never resets the experiment data, even if the configuration changes
  config.include_rails_helper = true
  # config.redis = "redis://custom.redis.url:6380"
  config.winning_alternative_recalculation_interval = 1.hour.to_i
end
