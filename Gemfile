# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# fwk/server
gem 'puma'
gem 'rails'

# db
gem 'activerecord-postgis-adapter' # pg extension for geo queries
gem 'pg'
gem 'pg_search'                    # pg search for autocomplete

# front end
gem 'caxlsx_rails'
gem 'react-rails'
gem 'slim-rails'
gem 'turbolinks'
gem 'webpacker'

# background jobs
gem 'delayed_job_active_record'
gem 'delayed_job_web'

# admin
gem 'rails_admin'
gem 'rails_admin-i18n'

# instrumentation
gem 'newrelic_rpm'
gem 'sentry-raven'

# acl
gem 'cancancan'
gem 'devise'
gem 'devise-i18n'

# model/utils
gem 'aasm'
gem 'discard'
gem 'kaminari'
# model/validators
gem 'email_inquire'
gem 'validates_zipcode'

# dev utils
gem 'bootsnap', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'foreman'
  gem 'rubocop'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'bullet'
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'activerecord-explain-analyze'
  gem 'letter_opener'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'minitest-reporters'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'rails-controller-testing'
  gem 'webdrivers'
  gem 'simplecov', require: false
end

group :test, :development do
  gem 'factory_bot_rails'
end

group :staging do
  gem 'rest-client' # not sure still in use?
end
