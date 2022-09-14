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
end
