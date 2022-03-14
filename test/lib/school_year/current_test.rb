# frozen_string_literal: true

require 'test_helper'
module SchoolYear
  class CurrentTest < ActiveSupport::TestCase
    test '.beginning_of_period / end_of_period from january to may' do
      travel_to(Date.new(2019, 1, 1)) do
        school_year = Current.new
        assert_equal Date.new(2018, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2019, 5, 31), school_year.end_of_period
      end
    end

    test '.beginning_of_period / end_of_period from june to september' do
      travel_to(Date.new(2019, 6, 1)) do
        school_year = Current.new
        assert_equal Date.new(2019, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2020, 5, 31), school_year.end_of_period
      end
    end

    test '.beginning_of_period / end_of_period overlap year shift' do
      travel_to(Date.new(2019, 5, 31)) do
        school_year = Current.new
        assert_equal Date.new(2019, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2020, 5, 31), school_year.end_of_period
      end
    end

    test 'beginning_of_period / end_of_period from september to december' do
      travel_to(Date.new(2019, 9, 1)) do
        school_year = Current.new
        assert_equal Date.new(2019, 9, 1), school_year.beginning_of_period
        assert_equal Date.new(2020, 5, 31), school_year.end_of_period
      end
    end

  end
end
