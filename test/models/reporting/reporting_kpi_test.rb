require 'test_helper'

class ReportingKpiTest < ActiveSupport::TestCase
  test 'last_week_kpis' do
    current_week = Week.selectable_from_now_until_end_of_school_year.first
    last_week = Week.find(current_week.id.to_i - 2)
    last_monday = last_week.week_date
    last_sunday = last_monday + 6.days
    school_manager = create(:school_manager, school: create(:school))
    internship_offer = create(
      :weekly_internship_offer,
      max_candidates: 2,
      weeks: Week.selectable_from_now_until_end_of_school_year.first(2).to_a
    )
    expected = {
      subscriptions: {},
      applications_count: 0,
      student_applyers_count: 0,
      offers_count: 1,
      seats_count: 2
    }
    assert_equal expected, Reporting::Kpi.new.last_week_kpis(
      last_monday: last_monday,
      last_sunday: last_sunday
    )
    student = create(:student)
    assert_equal expected, Reporting::Kpi.new.last_week_kpis(
      last_monday: last_monday,
      last_sunday: last_sunday
    )

    student.update_columns(updated_at: Date.today - 7.days, created_at: Date.today - 7.days )
    updated_expected = {
      subscriptions: {"Elève"=>1},
      applications_count: 0,
      student_applyers_count: 0,
      offers_count: 1,
      seats_count: 2
    }
    assert_equal updated_expected, Reporting::Kpi.new.last_week_kpis(
      last_monday: last_monday,
      last_sunday: last_sunday
    )
    internship_application = create(:weekly_internship_application, :approved, student: student, internship_offer: internship_offer)
    assert_equal updated_expected, Reporting::Kpi.new.last_week_kpis(
      last_monday: last_monday,
      last_sunday: last_sunday
    )
    internship_application.update_columns(updated_at: Date.today - 7.days, created_at: Date.today - 7.days )
    new_updated_expected = {
      subscriptions: {"Elève"=>1},
      applications_count: 1,
      student_applyers_count: 1,
      offers_count: 1,
      seats_count: 2
    }
    assert_equal new_updated_expected, Reporting::Kpi.new.last_week_kpis(
      last_monday: last_monday,
      last_sunday: last_sunday
    )
  end
end