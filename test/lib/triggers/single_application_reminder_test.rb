# frozen_string_literal: true

require 'test_helper'

module Triggers
  class SingleApplicationReminderTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test '.enqueue_all does queue 2nd recall job when internship_application count is equal to 1' do
      travel_to Date.new(2020, 9, 1) do
        internship_application = create(:weekly_internship_application, :drafted)
        assert_enqueued_with(job: Triggered::SingleApplicationSecondReminderJob,
                             args: [internship_application.student.id]) do
          internship_application.submit
        end
      end
    end

  end
end
