# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'minitest/reporters'
require 'minitest/autorun'
require 'rails/test_help'
require 'capybara-screenshot/minitest'
require 'support/api_test_helpers'
require 'support/third_party_test_helpers'
require 'support/search_internship_offer_helpers'
require 'support/email_spam_euristics_assertions'
require 'support/organisation_form_filler'
require 'support/internship_offer_info_form_filler'
require 'support/tutor_form_filler'
require 'minitest/retry'
require 'webmock/minitest'

Minitest::Retry.use!(
  retry_count: 3,
  verbose: true,
  io: $stdout,
  exceptions_to_retry: [
    ActionView::Template::Error, # during test, sometimes fails on "unexpected token at ''", not fixable
    PG::InternalError # sometimes postgis ref system is not yet ready
  ]
)
Minitest::Reporters.use!

WebMock.disable_net_connect!(
  allow: [
    /127\.0\.0\.1/,
    /github.com/,
    /github-production-release-asset*/,
    /chromedriver\.storage\.googleapis\.com/,
    /api-adresse.data.gouv.fr/
  ]
)

Capybara.save_path = Rails.root.join('tmp/screenshots')

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize_setup do |_worker|
    # setup databases
    # if ENV['CI'].blank?
    #   postgis_spatial_ref_sys_path = Rails.root.join('db/test/spatial_ref_sys.sql')
    #   postgis_spatial_ref_sys_sql = File.read(postgis_spatial_ref_sys_path)
    #   ActiveRecord::Base.connection.execute(postgis_spatial_ref_sys_sql)
    # end
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
