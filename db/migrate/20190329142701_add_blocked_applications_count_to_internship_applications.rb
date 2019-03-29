class AddBlockedApplicationsCountToInternshipApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_applications, :blocked_applications_count, :integer, default: 0, null: false
  end
end
