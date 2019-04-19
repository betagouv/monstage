class AddAcceptedAtToInternshipApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_applications, :approved_at, :datetime
    add_column :internship_applications, :rejected_at, :datetime
    add_column :internship_applications, :convention_signed_at, :datetime
  end
end
