# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: ENV.fetch('BROWSER') { 'headless_chrome' }.to_sym

  include Devise::Test::IntegrationHelpers
  include Html5Validator

  def setup
    stub_request(:any, /api-adresse.data.gouv.fr/)
        .to_return(status: 200, body: File.read(Rails.root.join(*%w[test
                                                                  fixtures
                                                                  files
                                                                  api-address-paris-13.json])))
  end
end
