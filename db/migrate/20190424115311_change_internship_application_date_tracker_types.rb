class ChangeInternshipApplicationDateTrackerTypes < ActiveRecord::Migration[5.2]
  def change
    change_column :internship_applications, :approved_at, :datetime
    change_column :internship_applications, :rejected_at, :datetime
    change_column :internship_applications, :convention_signed_at, :datetime
    change_column :internship_applications, :submitted_at, :datetime
  end
end
