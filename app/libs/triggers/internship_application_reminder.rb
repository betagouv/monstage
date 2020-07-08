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
      # internship_applications = employer.internship_applications
      [
        InternshipApplication.joins(:internship_offer)
                             .where("internship_offers.employer_id = #{employer.id}")
                             .remindable,
        InternshipApplication.joins(:internship_offer)
                             .where("internship_offers.employer_id = #{employer.id}")
                             .expirable
      ].map(&:count).any?(&:positive?)
    end

    def notify(employer)
      Triggered::InternshipApplicationsReminderJob.perform_later(employer)
    end
  end
end
