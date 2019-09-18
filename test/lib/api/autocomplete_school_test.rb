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

    test '.as_json concat match_by_city' do
      result = AutocompleteSchool.new(term: @school_city, limit: 5).as_json
      assert_not_empty result[:match_by_city]
      assert_empty result[:match_by_name]
    end

    test '.as_json concat match_by_name' do
      result = AutocompleteSchool.new(term: @school_name, limit: 5).as_json
      assert_empty result[:match_by_city]
      assert_not_empty result[:match_by_name]
    end
  end
end
