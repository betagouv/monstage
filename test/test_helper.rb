# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'minitest/reporters'
require 'minitest/autorun'
require 'rails/test_help'
require 'capybara-screenshot/minitest'
# require "capybara/cuprite"
require 'support/api_test_helpers'
require 'minitest/retry'
require 'webmock/minitest'

Minitest::Retry.use!(
  retry_count:  3,
  verbose: true,
  io: $stdout,
  exceptions_to_retry: [
    ActionView::Template::Error, # during test, sometimes fails on "unexpected token at ''", not fixable
    PG::InternalError,           # sometimes postgis ref system is not yet ready
  ]
)

WebMock.disable_net_connect!(
  allow: [
    /127\.0\.0\.1/,
    /chromedriver\.storage\.googleapis\.com/
  ]
)

Capybara.save_path = Rails.root.join('tmp/screenshots')

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    **{
      window_size: [1200, 800],
      # See additional options for Dockerized environment in the respective section of this article
      browser_options: {},
      # Increase Chrome startup wait time (required for stable CI builds)
      process_timeout: 10,
      # Enable debugging capabilities
      inspector: true,
      # Allow running Chrome in a headful mode by setting HEADLESS env
      # var to a falsey value
      headless: !ENV["HEADLESS"].in?(%w[n 0 no false])
    }
  )
end

Capybara.default_driver = Capybara.javascript_driver = :cuprite

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize_setup do |worker|
    # setup databases
    if ENV['CI'].blank?
      postgis_spatial_ref_sys_path = Rails.root.join('db/test/spatial_ref_sys.sql')
      postgis_spatial_ref_sys_sql = File.read(postgis_spatial_ref_sys_path)
      ActiveRecord::Base.connection.execute(postgis_spatial_ref_sys_sql)
    end
  end

  parallelize_teardown do |worker|
    # cleanup database
  end

  # Run tests in parallel with specified workers
  parallelize(workers: ENV.fetch('PARALLEL_WORKERS') { :number_of_processors })

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
