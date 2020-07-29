# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: ENV.fetch('BROWSER') { 'headless_chrome' }.to_sym
end
