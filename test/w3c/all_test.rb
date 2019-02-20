require 'test_helper'

class HomeValidationTest < ActionDispatch::IntegrationTest
  include Html5Validator

  test 'root_path' do
    run_request_and_cache_response(report_as: 'root_path') do
      get root_path
    end
  end

  test 'internship_offers_path' do
    run_request_and_cache_response(report_as: 'internship_offers_path') do
      get internship_offers_path
    end
  end

  test 'new_internship_offer_path'  do
    run_request_and_cache_response(report_as: 'new_internship_offer_path') do
      get new_internship_offer_path
    end
  end
end
