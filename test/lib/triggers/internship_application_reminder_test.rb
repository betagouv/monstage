# frozen_string_literal: true

require 'test_helper'

module Triggers
  class InternshipApplicationReminderTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test '.enqueue_all do not queue not queues job ' \
         'when internship_applications is pending for less than a week' do
      @internship_offer = create(:weekly_internship_offer)
      @reminder_service = InternshipApplicationReminder.new
      create(:weekly_internship_application, :submitted,
             submitted_at: 1.day.ago,
             internship_offer: @internship_offer)
      assert_no_enqueued_jobs do
        @reminder_service.enqueue_all
      end
    end

    test '.enqueue_all do queue when ' \
         'there is an internship_applications with pending status ' \
         'for more than 1 a week' do
      travel_to Date.new(2020,3,1) do
        @internship_offer = create(:weekly_internship_offer)
        @reminder_service = InternshipApplicationReminder.new
        create(:weekly_internship_application,
              :submitted,
              submitted_at: 8.days.ago,
              internship_offer: @internship_offer)

        assert_enqueued_with(job: Triggered::InternshipApplicationsReminderJob,
                            args: [@internship_offer.employer]) do
          @reminder_service.enqueue_all
        end
      end
    end

    test '.enqueue_all do queue when ' \
         'there is an internship_applications with pending status ' \
         'for more than 45 days' do
      travel_to Date.new(2020,3,1) do
        @internship_offer = create(:weekly_internship_offer)
        @reminder_service = InternshipApplicationReminder.new
        create(:weekly_internship_application,
               :submitted,
               submitted_at: (InternshipApplication::EXPIRATION_DURATION + 1).ago,
               internship_offer: @internship_offer)

        assert_enqueued_with(job: Triggered::InternshipApplicationsReminderJob,
                             args: [@internship_offer.employer]) do
          @reminder_service.enqueue_all
        end
      end
    end
  end
end
