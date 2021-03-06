# frozen_string_literal: true

module Triggers
  # safe re-entrant code to send notifications
  class InternshipApplicationReminder
    def enqueue_all
      Users::Employer.find_each do |employer|
        notify(employer) if notifiable?(employer)
      end
    end

    def notifiable?(employer)
      internship_applications = employer.internship_applications
      [
        internship_applications.remindable,
        internship_applications.expirable
      ].map(&:count).any?(&:positive?)
    end

    def notify(employer)
      Triggered::InternshipApplicationsReminderJob.perform_later(employer)
    end
  end
end
