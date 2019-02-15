require 'test_helper'
require 'fileutils'

# CircleCI task w3c validation depends on this path
RESPONSE_STORED_DIR = Rails.root.join('tmp', 'w3c')

Dir["#{RESPONSE_STORED_DIR}/*"].map do |last_run|
  FileUtils.rm(last_run)
end

class HomeValidationTest < ActionDispatch::IntegrationTest

  def w3c_validate!(report_as:)
    yield
    basename = report_as.parameterize
    ext = '.html'

    File.open(RESPONSE_STORED_DIR.join("#{basename}#{ext}"), 'w+') do |fd|
      fd.write(response.body)
    end
  end

  test 'root_path' do
    w3c_validate!(report_as: 'root_path') do
      get root_path
    end
  end

  test 'internship_offers_path' do
    w3c_validate!(report_as: 'internship_offers_path') do
      get internship_offers_path
    end
  end

  test 'new_internship_offer_path'  do
    w3c_validate!(report_as: 'new_internship_offer_path') do
      get new_internship_offer_path
    end
  end

  # test 'edit_internship_offer_path'  do
  #   w3c_validate!(report_as: 'edit_internship_offer_path') do
  #     get edit_internship_offer_path(internship_offers(:one))
  #   end
  # end
end
