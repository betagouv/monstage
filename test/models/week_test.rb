# frozen_string_literal: true

require 'test_helper'

class WeekTest < ActiveSupport::TestCase
  test 'association internship_offer_weeks' do
    week = Week.new
    assert_equal week.internship_offer_weeks, []
  end

  test 'association weeks' do
    week = Week.new
    assert_equal week.internship_offers, []
  end

  test '#consecutive_to?' do
    week_before, week = Week.order(year: :asc, number: :asc).first(2)
    assert week.consecutive_to?(week_before)
    refute week_before.consecutive_to? week
  end

  test 'scope selectable_on_specific_school_year' do
    school_year = SchoolYear::Floating.new(date: Date.new(2021, 1, 1))
    weeks = Week.selectable_on_specific_school_year(school_year: school_year)
    result = weeks.all? do |w|
       (w.year == 2020 && w.number > 34) ||
       (w.year == 2021 && w.number <= 22)
    end
    assert result
  end

  test 'scope in_the_future' do
    assert Week.in_the_future.count > 52
    assert_equal 2050, Week.in_the_future.map(&:year).sort.last
    assert_equal 52, Week.in_the_future.sort_by(&:number).sort.last.number
    assert_equal 1, Week.in_the_future.sort_by(&:number).sort.last(52).first.number
  end

  test '.ahead_of_school_year_start?' do
    travel_to(Date.new(2021, 1, 7)) do
      refute Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2021, 5, 1)) do
      refute Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2021, 5, 31)) do
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2021, 6, 1)) do
      assert Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2021, 9, 1)) do
      refute Week.current.ahead_of_school_year_start?
    end
    travel_to(Date.new(2021, 9, 10)) do
      refute Week.current.ahead_of_school_year_start?
    end
  end
end
