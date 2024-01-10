# frozen_string_literal: true

module Triggers
  # safe re-entrant code to send notifications
  class SingleApplicationReminder
    def enqueue_all
      Users::Student.find_each do |student|
        Triggered::SingleApplicationReminderJob.set(wait: 2.days).perform_later(student.id)
        Triggered::SingleApplicationSecondReminderJob.set(wait: 5.days).perform_later(student.id)
      end
    end
  end
end
