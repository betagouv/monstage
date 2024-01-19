# frozen_string_literal: true

require 'test_helper'

module Triggered
  class StudentSmSInternshipApplicationsReminderJobTest < ActiveJob::TestCase
    include ActionMailer::TestHelper
    include ThirdPartyTestHelpers

    setup do
      @internship_offer = create(:weekly_internship_offer)
      ActionMailer::Base.deliveries = []
    end
    teardown { ActionMailer::Base.deliveries = [] }

    test 'perform does not send email when no pending internship_applications' do
      student = create(:student)
      internship_application = create(:weekly_internship_application, :submitted, student: student)
      sms_stub do
        assert_no_emails do
          Triggered::StudentSmsInternshipApplicationReminderJob.perform_now(internship_application.id)
        end
      end
    end

    test 'perform and send sms when pending internship_applications' do
      student = create(:student)
      internship_application = create(:weekly_internship_application, :validated_by_employer, student: student)
      sms_stub do
        assert_enqueued_jobs 1 do
          Triggered::StudentSmsInternshipApplicationReminderJob.perform_now(internship_application.id)
        end
      end
    end
  end
end