# frozen_string_literal: true

require 'test_helper'

# this app is BUILT FOR TWO PLATFORM : web/mobile
#
# our APPROACH/FOCUS is #1 web tech (easy of use/velocity)
#     + focus on mobile rendering first (easy with RWD to extend to desktop)
#
# DEPENDING OF THE TARGETED PLAFORM, FEATURES MAY DIFFER, so does testing
# e2e testing is addressed for both platform with focus on maintenance
# * mobile only shortcut: ./infra/system_mobile.sh [only mobile, capybara with a selenium driver, driving an chrome_headless + emulator]
# * desktop only shortcut: ./infra/system_desktop.sh [only desktop, capybara with a selenium driver, driving an chrome_headless]
#
# saying that, THE SUITE MUST BE CONSTRAINED TO ONLY RUN EACH KIND OF TEST (rails takes them all)
# to do so we use minitest TEST_OPTS flags :
# --name='pattern_to_run_tests_matching_a_pattern'
# --exclude='pattern_to_skip_tests_matching_a_pattern'
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  CAPYBARA_DRIVER = :selenium

  # usage: BROWSER=chrome|headless_chrome|firefox rails test:system TESTOPTS='--exclude /USE_IPHONE_EMULATION/'
  CAPYBARA_BROWSER = ENV.fetch('BROWSER') { 'headless_chrome' }.to_sym
  # usage: USE_IPHONE_EMULATION=true (or undef) rails test:system TESTOPTS='--name /^USE_IPHONE_EMULATION/'
  CAPYBARA_EMULATE_MOBILE = ENV.fetch('USE_IPHONE_EMULATION') { false }

  driven_by CAPYBARA_DRIVER, using: CAPYBARA_BROWSER do |driver_opts|
    # when ENV['USE_IPHONE_EMULATION'], use chrome emulation with iPhone 6
    driver_opts.add_emulation(device_name: 'iPhone 6') if CAPYBARA_EMULATE_MOBILE
  end

  def setup
    stub_request(:any, /api-adresse.data.gouv.fr/)
        .to_return(status: 200, body: File.read(Rails.root.join(*%w[test
                                                                  fixtures
                                                                  files
                                                                  api-address-paris-13.json])))
  end
end
