require 'test_helper'
module Presenters
  class WeekListTest < ActiveSupport::TestCase
    test '#first_joined_weeks' do
      first_weeks_trunck  = Week.where(year: 2019).order(number: :asc).first(3)
      second_weeks_trunck = [Week.where(year: 2020).order(number: :asc).last,
                             Week.find_by(year: 2021, number: 1)]
      weeks = first_weeks_trunck + second_weeks_trunck

      wl_1 = Presenters::WeekList.new(weeks: first_weeks_trunck)
      wl_2 = Presenters::WeekList.new(weeks: second_weeks_trunck)
      wl   = Presenters::WeekList.new(weeks: weeks)

      assert_equal 1, wl_1.split_weeks_in_trunks.count
      assert_equal wl_1.to_s, wl_1.split_weeks_in_trunks.first.to_s

      assert_equal 2, wl.split_weeks_in_trunks.count
      assert_equal wl_1.to_s, wl.split_weeks_in_trunks.first.to_s
      assert_equal wl_2.to_s, wl.split_weeks_in_trunks.second.to_s
    end

    test '#student_compatible_week_list' do
      first_weeks_trunck = Week.where(year: 2019).order(number: :asc).first(3)
      school = create(:school, weeks: [first_weeks_trunck.second])
      student = create(:student, school: school)
      wl_ref = Presenters::WeekList.new(weeks: [first_weeks_trunck.second])
      wl = Presenters::WeekList.new(weeks: first_weeks_trunck)

      assert_equal wl_ref.to_s, wl.student_compatible_week_list(student).to_s
    end
  end
end