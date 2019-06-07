# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.variable_size_secure_compare(Credentials.enc(:delayed_job, :username, prefix_env: false), username) &&
      ActiveSupport::SecurityUtils.variable_size_secure_compare(Credentials.enc(:delayed_job, :password, prefix_env: false), password)
  end
end
