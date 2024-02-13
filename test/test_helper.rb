# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'minitest/reporters'
require 'minitest/autorun'
require 'rails/test_help'
require 'capybara-screenshot/minitest'
require "view_component/test_case"
require 'support/api_test_helpers'
require 'support/third_party_test_helpers'
require 'support/search_internship_offer_helpers'
require 'support/email_spam_euristics_assertions'
require 'support/organisation_form_filler'
require 'support/school_form_filler'
require 'support/internship_offer_info_form_filler'
require 'support/practical_info_form_filler'
require 'support/tutor_form_filler'
require 'support/turbo_assertions_helper'
require 'support/team_and_areas_helper'
require 'minitest/retry'
require 'webmock/minitest'
# these two lines should be withdrawn whenever the ChromeDriver is ok
# https://stackoverflow.com/questions/70967207/selenium-chromedriver-cannot-construct-keyevent-from-non-typeable-key/70971698#70971698
require 'webdrivers/chromedriver'

# version 115 is not working with chromedriver-helper
# Webdrivers::Chromedriver.required_version = "114.0.5735.90"

Capybara.save_path = Rails.root.join('tmp/screenshots')

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
    /googlechromelabs.github.io/,
    /edgedl.me.gvt1.com/,
    /api-adresse.data.gouv.fr/,
    /education.gouv.fr\/annuaire/
  ]
)

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Run tests in parallel with specified workers
  parallelize(workers: ENV.fetch('PARALLEL_WORKERS') { :number_of_processors })

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
