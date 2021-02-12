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
end
