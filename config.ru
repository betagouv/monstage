# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
use Rack::Deflater
run Rails.application

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    Credentials.enc(:delayed_job, :username, prefix_env: false) == username &&
      Credentials.enc(:delayed_job, :password, prefix_env: false) == password
  end
end
