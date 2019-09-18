# frozen_string_literal: true

require 'test_helper'

module Api
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers

    def assert_hash_contains(a, b)
      assert (a.to_a - b.to_a).empty?, "contains fail:\n #{a}\n is not contained in\n #{b}"
    end

    test 'empty searh works' do
      post search_api_schools_path, params: {  }
      assert_response :success
    end

    test 'search with term works' do
      parisian_school = create(:api_school, city: "Paris", zipcode:"75015")
      parisian_school.reload # ensure triggered city_tsv had been reloaded

      post search_api_schools_path, params: { query: "Paris" }
      parisian_schools_key = json_response.keys.first
      first_parisian_school = json_response[parisian_schools_key].first

      # assert_hash_contains(JSON.parse(parisian_school.to_json).except("pg_search_highlight"),
      #                      first_parisian_school.except("pg_search_highlight"))
    end
  end
end
