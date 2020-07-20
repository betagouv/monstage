# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
    driven_by :selenium, using: ENV.fetch('CHROME') { 'headless_chrome' }
end
