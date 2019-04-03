source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
gem 'webpacker'
gem 'turbolinks'
gem 'pg'
gem 'activerecord-postgis-adapter' # postgis extension

# Use Puma as the app server
gem 'puma'
gem 'bootsnap', require: false

# gem 'geocoder'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end
gem 'delayed_job_active_record'

# could it be only on build stage?
gem 'jekyll'
gem 'minima'

group :jekyll_plugins do
end

group :development do
  gem 'foreman'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  gem 'listen'
  gem 'bullet'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'minitest-reporters'
  gem 'capybara'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'rails-controller-testing'
end

group :test, :development do
  gem 'factory_bot_rails'
end

group :staging do
  gem 'rest-client'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]



gem 'slim-rails'
gem 'discard'

gem 'sentry-raven'

gem 'devise'
gem 'devise-i18n'
gem 'cancancan'

gem 'kaminari'
gem 'counter_culture'

gem 'aasm'
