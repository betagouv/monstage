class AddPendingReminderSentAtToInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_applications, :pending_reminder_sent_at, :date
  end
end
