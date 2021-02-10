# frozen_string_literal: true

module Triggers
  # safe re-entrant code to send notifications
  class SchoolMissingWeeksReminder
    def enqueue_all
      School.without_weeks_on_current_year
            .with_manager
            .missing_school_week_count_gt(0)
            .find_each
            .map do |school|
        notify(school)
      end
    end

    def notify(school)
      SchoolManagerMailer.missing_school_weeks(school_manager: school.school_manager)
                         .deliver_later
    end
  end
end
