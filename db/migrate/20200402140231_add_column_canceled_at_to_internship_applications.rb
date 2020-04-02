class AddColumnCanceledAtToInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_applications, :canceled_at, :datetime
  end
end
