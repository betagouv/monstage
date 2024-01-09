# frozen_string_literal: true

module Triggers
  # safe re-entrant code to send notifications
  class SingleApplicationReminder
    def enqueue_all
      Users::Student.find_each do |student|
        notify(student) if notifiable?(student, 2)
        notify_again(student) if notifiable?(student, 5)
      end
    end

    def notifiable?(student, delay)
      student.has_offers_to_apply_to? &&
        student.internship_applications.count == 1 &&
        student.has_applied?(delay.days.ago)
    end

    def notify(student)
      Triggered::SingleApplicationReminderJob.perform_later(student.id)
    end

    def notify_again(student)
      Triggered::SingleApplicationSecondReminderJob.perform_later(student.id)
    end
  end
end
