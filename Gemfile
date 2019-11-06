# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'pg'
gem 'activerecord-postgis-adapter' # pg extension for geo queries
gem 'pg_search'                    # pg search for autocomplete
gem 'rails'
gem 'turbolinks'
gem 'webpacker'
gem 'react-rails'

# Use Puma as the app server
gem 'bootsnap', require: false
gem 'newrelic_rpm'
gem 'puma'

gem 'geocoder'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'activerecord-explain-analyze'

group :development do
  gem 'foreman'
  gem 'rubocop'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'bullet'
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'minitest-reporters'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'webdrivers'
  gem 'rails-controller-testing'
end

group :test, :development do
  gem 'factory_bot_rails'
end

group :staging do
  gem 'rest-client'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'discard'
gem 'slim-rails'

gem 'sentry-raven'

gem 'cancancan'
gem 'devise'
gem 'devise-i18n'

gem 'aasm'
gem 'kaminari'

# Admin
gem "switch_user"
gem 'rails_admin'
gem 'rails_admin-i18n'
gem 'rails_admin_aasm'

gem 'zammad_api'
gem 'email_inquire'
