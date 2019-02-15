require 'test_helper'
require 'fileutils'

class HomeValidationTest < ActionDispatch::IntegrationTest
  # CircleCI task w3c validation depends on this path
  RESPONSE_STORED_DIR = Rails.root.join('tmp', 'w3c')

  setup do
    Dir["#{RESPONSE_STORED_DIR}/*"].map do |last_run|
      FileUtils.rm(last_run)
    end
  end

  def w3c_validate!(report_as:)
    yield
    basename = report_as.parameterize
    ext = '.html'

    File.open(RESPONSE_STORED_DIR.join("#{basename}#{ext}"), 'w+') do |fd|
      fd.write(response.body)
    end
  end

  test "the truth" do
    w3c_validate!(report_as: 'home') do
      get "/"
    end
  end
end
