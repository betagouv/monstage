# frozen_string_literal: true

require 'application_system_test_case'

module Product
  class InternshipOffersTest < ApplicationSystemTestCase
    include Html5Validator
    include Devise::Test::IntegrationHelpers

    test 'USE_W3C, internship_offers_path' do
      %i[employer
         student
         school_manager].each do |role|
        run_request_and_cache_response(report_as: "internship_offers_path_#{role}") do
          sign_in(create(role))
          # visit internship_offers_path TO DO Fix role button on Pin map
        end
      end
    end

    test 'USE_W3C, internship_offer_path' do
      %i[employer student].each do |role|
        run_request_and_cache_response(report_as: "internship_offer_path_#{role}") do
          sign_in(create(role))
          # visit internship_offer_path(create(:weekly_internship_offer).to_param) TO DO Fix role button on Pin map
        end
      end
    end

    test 'USE_W3C, search_internship_offer_path' do
      run_request_and_cache_response(report_as: "search_internship_offer_path") do
        visit search_internship_offers_path
      end
    end
  end
end
