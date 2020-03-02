# frozen_string_literal: true

require 'test_helper'

module Triggers
  class SchoolMissingWeeksReminderTest < ActiveSupport::TestCase
    include ActionMailer::TestHelper

    test '.enqueue_all only queues email when ' \
         'there is a school_manager and ' \
         'missing_school_weeks_count > 0' do
      reminder_service = SchoolMissingWeeksReminder.new
      create(:school, weeks: [], school_manager: nil)
      reminder_service.enqueue_all
      assert_enqueued_emails 0

      create(:school, weeks: [],
                      school_manager: create(:school_manager),
                      missing_school_weeks_count: 0)
      reminder_service.enqueue_all
      assert_enqueued_emails 0

      create(:school, weeks: [],
                      school_manager: create(:school_manager),
                      missing_school_weeks_count: 1)
      reminder_service.enqueue_all
      assert_enqueued_emails 1
    end
  end
end
