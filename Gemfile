# frozen_string_literal: true


source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# fwk/server
gem 'actionpack', ">= 6.1.3.2"
gem "rails", "~> 6.1.4.4"
gem 'puma'

# db
gem 'pg'
# pg extension for geo queries
# wait for : https://github.com/rgeo/activerecord-postgis-adapter/tree/ar61 to be merge into master
gem 'activerecord-postgis-adapter'

# don't bump until fixed, https://github.com/Casecommons/pg_search/issues/446
gem 'pg_search', '2.3.2'                    # pg search for autocomplete
gem 'prawn'
gem 'prawn-styled-text'

# front end
gem 'uglifier'
gem 'inline_svg'
gem 'slim-rails'
gem 'turbolinks'
gem "react_on_rails"
gem 'webpacker'
gem 'caxlsx_rails'
gem "split", require: "split/dashboard"

# background jobs
gem 'sidekiq'
gem 'redis-namespace' # plug redis queues on same instance for prod/staging

# admin
gem 'rails_admin'
gem 'rails_admin-i18n'

# instrumentation
gem "lograge"
gem 'ovh-rest'
gem 'prismic.io', require: 'prismic'
gem "sentry-ruby"
gem "sentry-rails"
gem 'airtable'
gem 'geocoder'
gem 'bitly'

# acl
gem 'cancancan'
gem 'devise'
gem 'devise-i18n'

# model/utils
gem 'discard'
gem 'aasm'
gem 'kaminari'
# model/validators
gem 'validates_zipcode'
gem 'email_inquire'

# dev utils
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'bootsnap', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
end

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
  gem 'letter_opener'
  gem 'activerecord-explain-analyze'
end

group :test do
  # External api calls isolation
  gem 'webmock'
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'minitest-reporters'
  gem 'minitest-retry'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'webdrivers'
  gem 'rails-controller-testing'
  gem 'capybara-screenshot'
end

group :review do
  gem 'rest-client' # used by mailtrap for review apps
end

group :test, :development, :review do
  gem 'factory_bot_rails'
end


