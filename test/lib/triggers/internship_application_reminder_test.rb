# frozen_string_literal: true

require 'test_helper'

module Triggers
  class InternshipApplicationReminderTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      @internship_offer = create(:internship_offer)
      @reminder_service = InternshipApplicationReminder.new
    end

    test '.enqueue_all do not queue not queues job ' \
         'when internship_applications is pending for less than a week' do
      create(:internship_application, :submitted,
             submitted_at: 1.day.ago,
             internship_offer: @internship_offer)
      assert_no_enqueued_jobs do
        @reminder_service.enqueue_all
      end
    end

    test '.enqueue_all do queue when ' \
         'there is an internship_applications with pending status ' \
         'for more than 1 a week' do
      create(:internship_application,
             :submitted,
             submitted_at: 8.days.ago,
             internship_offer: @internship_offer)

      assert_enqueued_with(job: Triggered::InternshipApplicationsReminderJob,
                           args: [@internship_offer.employer]) do
        @reminder_service.enqueue_all
      end
    end

    test '.enqueue_all do queue when ' \
         'there is an internship_applications with pending status ' \
         'for more than 45 days' do
      create(:internship_application,
             :submitted,
             submitted_at: InternshipApplication::EXPIRATION_DURATION.ago,
             internship_offer: @internship_offer)

      assert_enqueued_with(job: Triggered::InternshipApplicationsReminderJob,
                           args: [@internship_offer.employer]) do
        @reminder_service.enqueue_all
      end
    end
  end
end
