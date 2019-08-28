# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'minitest/reporters'
require 'minitest/autorun'
require 'rails/test_help'

require 'support/api_test_helpers'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize_setup do |worker|
    # setup databases
  end

  parallelize_teardown do |worker|
    # cleanup database
  end

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
