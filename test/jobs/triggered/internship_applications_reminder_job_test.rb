# frozen_string_literal: true

require 'test_helper'

module Triggered
  class InternshipApplicationsReminderJobTest < ActiveJob::TestCase
    include ActionMailer::TestHelper

    # @warning: sometimes it fails ; surprising,
    # try to empty deliveries before running the spec
    setup do
      @internship_offer = create(:weekly_internship_offer)
      ActionMailer::Base.deliveries = []
    end
    teardown { ActionMailer::Base.deliveries = [] }

    test 'perform does not send email ' \
         'when internship_applications is pending for less than a week' do
      internship_application = create(:weekly_internship_application, :submitted,
                                      submitted_at: 1.day.ago,
                                      internship_offer: @internship_offer)
      InternshipApplicationsReminderJob.perform_now(@internship_offer.employer)
      internship_application.reload
      assert_nil internship_application.pending_reminder_sent_at
      assert_nil internship_application.expired_at
      assert internship_application.submitted?
    end

    test 'perform sends email and update pending_reminder_sent_at' \
         'when internship_applications is pending for more than 1 a week' do
      internship_application = nil
      assert_enqueued_emails 1 do #one for student welcome messaging
        internship_application = create(:weekly_internship_application, :submitted,
                                        submitted_at: 8.days.ago,
                                        internship_offer: @internship_offer)
      end
      freeze_time do
        assert_changes -> { internship_application.reload.pending_reminder_sent_at },
                      from: nil,
                      to: Time.now.utc do
          InternshipApplicationsReminderJob.perform_now(@internship_offer.employer)
          assert_enqueued_emails 2 # one for employer
        end
        assert_nil internship_application.expired_at
        assert_equal DateTime.now, internship_application.pending_reminder_sent_at

        assert_no_emails do # ensure re-entrance does not send emails
          InternshipApplicationsReminderJob.perform_now(@internship_offer.employer)
        end
      end
    end

    test 'perform does sends email and expire!' \
         'when internship_applications is pending for more than 45 days' do
      internship_application = nil
      assert_enqueued_emails 1 do #one for student welcome messaging
        internship_application = create(:weekly_internship_application, :submitted,
                                        submitted_at: (InternshipApplication::EXPIRATION_DURATION + 1.day).ago,
                                        pending_reminder_sent_at: 7.days.ago,
                                        internship_offer: @internship_offer)
      end      

      freeze_time do
        assert_changes -> { internship_application.reload.expired? },
                       from: false,
                       to: true do
          InternshipApplicationsReminderJob.perform_now(@internship_offer.employer)
          assert_enqueued_emails 2 # one for employer
        end
        internship_application.reload
        assert_equal Time.now.utc, internship_application.expired_at, 'expired_at not updated'
        refute_equal DateTime.now, internship_application.pending_reminder_sent_at
      end
      assert_no_emails do # ensure re-entrance does not send emails
        InternshipApplicationsReminderJob.perform_now(@internship_offer.employer)
      end
    end
  end
end
