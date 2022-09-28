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

  test 'scope in_the_future' do
    assert Week.in_the_future.count > 52
    assert_equal 2050, Week.in_the_future.map(&:year).sort.last
    assert_equal 52, Week.in_the_future.sort_by(&:number).sort.last.number
    assert_equal 1, Week.in_the_future.sort_by(&:number).sort.last(52).first.number
  end
end
