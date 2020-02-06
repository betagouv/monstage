class AddPendingReminderSentAtToInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_applications, :expired_at, :datetime
    add_column :internship_applications, :pending_reminder_sent_at, :datetime
  end
end
