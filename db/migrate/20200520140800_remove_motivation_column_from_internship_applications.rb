class RemoveMotivationColumnFromInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    remove_column :internship_applications, :motivation
  end
end
