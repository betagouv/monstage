# frozen_string_literal: true

module Triggered
  class InternshipApplicationsReminderJob < ApplicationJob
    queue_as :batches

    def perform(employer)
      return unless current_trigger.notifiable?(employer)

      # cache ids otherwise notifiable behaviour is changed
      internship_applications = employer.internship_applications

      remindable_application_ids = internship_applications.remindable.pluck(:id)
      expirable_application_ids = internship_applications.expirable.pluck(:id)

      # in case of error rollback everything
      ActiveRecord::Base.transaction do
        update_remindable(remindable_application_ids)
        update_and_expire_expirable(expirable_application_ids)

        notify(employer: employer,
               remindable_application_ids: remindable_application_ids)
      end
    end

    private

    def current_trigger
      Triggers::InternshipApplicationReminder.new
    end

    def update_remindable(ids)
      InternshipApplication.where(id: ids)
                           .update_all(pending_reminder_sent_at: Time.now.utc)
    end

    def update_and_expire_expirable(ids)
      InternshipApplication.where(id: ids)
                           .each(&:expire!)
    end

    def notify(employer:,
               remindable_application_ids:)
      EmployerMailer.internship_applications_reminder_email(employer: employer,
                                                            remindable_application_ids: remindable_application_ids)
                    .deliver_later
    end
  end
end
