# frozen_string_literal: true

require 'test_helper'

module W3c
  class InternshipOffersTest < ActionDispatch::IntegrationTest
    include Html5Validator
    include Devise::Test::IntegrationHelpers

    test 'internship_offers_path' do
      %i[employer
         student
         school_manager].each do |role|
        run_request_and_cache_response(report_as: "internship_offers_path_#{role}") do
          sign_in(create(role))
          get internship_offers_path
          assert_response :success
        end
      end
    end

    test 'internship_offer_path' do
      %i[employer student].each do |role|
        run_request_and_cache_response(report_as: "internship_offer_path_#{role}") do
          sign_in(create(role))
          get internship_offer_path(create(:internship_offer).to_param)
          assert_response :success
        end
      end
    end

    test 'new_internship_offer_path' do
      sign_in(create(:employer))
      run_request_and_cache_response(report_as: 'new_dashboard_internship_offer_path') do
        get new_dashboard_internship_offer_path
        assert_response :success
      end
    end
  end
end
