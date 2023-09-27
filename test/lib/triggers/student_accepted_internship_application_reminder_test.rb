# frozen_string_literal: true

require 'test_helper'

module Triggers
  class InternshipApplicationReminderTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @student = create(:student)
      @reminder_service = Triggers::StudentAcceptedInternshipApplicationReminder.new
    end

    test '.enqueue_all does not queue not queues job ' \
         'when internship_application validated_by_employer ' \
         'is for less or more than 2 days old' do
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        validated_by_employer_at: 1.day.ago,
        student: @student)
      assert_no_enqueued_jobs do
        @reminder_service.enqueue_all
      end
    end
    test '.enqueue_all does not queue not queues job ' \
         'when internship_application are not validated_by_employer only' do
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        student: @student)
      internship_application = create(
        :weekly_internship_application,
        :approved,
        student: @student)
      assert_no_enqueued_jobs do
        @reminder_service.enqueue_all
      end
    end

    test '.enqueue_all do queue job ' \
         'when internship_application validated_by_employer ' \
         'is 2 days old or more' do
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        validated_by_employer_at: 2.day.ago + 2.hours,
        student: @student)
      assert_enqueued_jobs 1 do
        @reminder_service.enqueue_all
      end
    end

    test '.enqueue_all do queue job ' \
         'when internship_application validated_by_employer ' \
         'is 3 days old or more' do
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        validated_by_employer_at: 4.days.ago - 2.hours,
        student: @student)
      assert_enqueued_jobs 1 do
        @reminder_service.enqueue_all
      end
    end
  end
end
