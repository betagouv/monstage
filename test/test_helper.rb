# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'minitest/reporters'
require 'minitest/autorun'
require 'rails/test_help'
require 'capybara-screenshot/minitest'
require 'support/api_test_helpers'
require 'minitest/retry'
require 'webmock/minitest'

WebMock.disable_net_connect!(allow_localhost: true)

Minitest::Retry.use!(
  retry_count:  3,
  verbose: true,
  io: $stdout,
  exceptions_to_retry: [
    ActionView::Template::Error, # during test, sometimes fails on "unexpected token at ''", not fixable
    DRb::DRbRemoteError          # sometimes capybara is too quick to run a test
  ]
)

Capybara.save_path = Rails.root.join('tmp/screenshots')
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    stub_request(
      :any,
      "https://api.sendgrid.com/v3/marketing/contacts"
    ).to_return(status: 200, body: "", headers: {})

    stub_request(
      :any,
      "https://api.sendgrid.com/v3/marketing/contacts/search"
    ).to_return(status: 200, body: "{\"result\":[]}", headers: {})
  end

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
