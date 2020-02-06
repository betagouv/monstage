# frozen_string_literal: true

require 'test_helper'

module Api
  class AutocompleteSchoolTest < ActiveSupport::TestCase
    setup do
      @school_city = 'Orléans'
      @school_name = 'Jean'
      @orleans = create(:api_school, city: @school_city,
                                     name: @school_name)
    end

    test '.as_json concat match_by_city with full match' do
      result = AutocompleteSchool.new(term: @school_city, limit: 5).as_json
      assert_equal 1, result[:match_by_city].size
      assert_equal 0, result[:match_by_name].size
    end

    test '.as_json concat match_by_city with partial match' do
      0.upto(@school_city.size).map do |str_len|
        result = AutocompleteSchool.new(term: @school_city[0..str_len], limit: 5).as_json
        assert_equal 1, result[:match_by_city].size
        assert_equal 0, result[:match_by_name].size
      end
    end

    test '.as_json concat match_by_name with full match' do
      result = AutocompleteSchool.new(term: @school_name, limit: 5).as_json
      assert_equal 0, result[:match_by_city].size
      assert_equal 1, result[:match_by_name].size
    end

    test '.as_json concat match_by_name with partial match' do
      0.upto(@school_name.size).map do |str_len|
        result = AutocompleteSchool.new(term: @school_name, limit: 5).as_json
        assert_equal 0, result[:match_by_city].size
        assert_equal 1, result[:match_by_name].size
      end
    end

    test '.as_json with dasherized city names' do
      create(:api_school, city: "Mantes-la-Jolie")
      result = AutocompleteSchool.new(term: "Mantes la jolie", limit: 5).as_json
      assert_equal 1, result[:match_by_city].size
    end
  end
end
