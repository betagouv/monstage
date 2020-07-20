# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: ENV['CHROME'] ? :chrome : :headless_chrome
  driven_by :selenium, using: :firefox
end
