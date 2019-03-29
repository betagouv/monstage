class AddBlockedApplicationsCountToInternshipApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offer_weeks, :blocked_applications_count, :integer, default: 0, null: false
  end
end
