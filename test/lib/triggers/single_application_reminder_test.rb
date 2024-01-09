# frozen_string_literal: true

require 'test_helper'

module Triggers
  class SingleApplicationReminderTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test '.enqueue_all do not queue job ' \
         'when internship_application count is zero' do
      weeks_till_end = Week.selectable_from_now_until_end_of_school_year
      school = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
      student = create(:student, school: school)
      internship_offer = create(:weekly_internship_offer)
      reminder_service = SingleApplicationReminder.new
      assert_no_enqueued_jobs do
        reminder_service.enqueue_all
      end
    end

    test '.enqueue_all do not queue job ' \
         'when internship_application count is greater than 1' do
      travel_to Date.new(2020,3,1) do
        weeks_till_end   = Week.selectable_from_now_until_end_of_school_year
        school           = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
        student          = create(:student, school: school)
        internship_offer = create(:weekly_internship_offer, weeks: weeks_till_end)
        2.times { create(:weekly_internship_application, :submitted, student: student, week: weeks_till_end.first)}
        reminder_service = SingleApplicationReminder.new
        assert_no_enqueued_jobs do
          reminder_service.enqueue_all
        end
      end
    end

    test '.enqueue_all does queue job when internship_application count is equal to 1' do
      travel_to Date.new(2020, 9, 1) do
        weeks_till_end         = Week.selectable_from_now_until_end_of_school_year
        school                 = create(:school, :with_school_manager, weeks: weeks_till_end)
        student                = create(:student, school: school)
        internship_offer       = create(:weekly_internship_offer, weeks: weeks_till_end)
        create(:weekly_internship_application, 
               :submitted,
               submitted_at: 2.days.ago,
               student: student,
               week: weeks_till_end.first)
        reminder_service       = SingleApplicationReminder.new
        assert_enqueued_with(job: Triggered::SingleApplicationReminderJob,
                             args: [student.id]) do
          reminder_service.enqueue_all
        end
      end
    end

    test '.enqueue_all does queue 2nd recall job when internship_application count is equal to 1' do
      travel_to Date.new(2020, 9, 1) do
        weeks_till_end         = Week.selectable_from_now_until_end_of_school_year
        school                 = create(:school, :with_school_manager, weeks: weeks_till_end)
        student                = create(:student, school: school)
        internship_offer       = create(:weekly_internship_offer, weeks: weeks_till_end)
        create(:weekly_internship_application, 
               :submitted,
               submitted_at: 5.days.ago,
               student: student,
               week: weeks_till_end.first)
        reminder_service       = SingleApplicationReminder.new
        assert_enqueued_with(job: Triggered::SingleApplicationSecondReminderJob,
                             args: [student.id]) do
          reminder_service.enqueue_all
        end
      end
    end

    test '.enqueue_all does not queue job when internship_application count is equal to 1 but delay is wrong' do
      travel_to Date.new(2020, 9, 1) do
        weeks_till_end         = Week.selectable_from_now_until_end_of_school_year
        school                 = create(:school, :with_school_manager, weeks: weeks_till_end)
        student                = create(:student, school: school)
        internship_offer       = create(:weekly_internship_offer, weeks: weeks_till_end)
        # 2 days ago ==> 3 days ago : fail !
        create(:weekly_internship_application, 
               :submitted,
               submitted_at: 3.days.ago,
               student: student,
               week: weeks_till_end.first)
        reminder_service = SingleApplicationReminder.new
        assert_no_enqueued_jobs do
          reminder_service.enqueue_all
        end
      end
    end
  end
end
