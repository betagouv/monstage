class AddTypeToInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_applications, :type, :string, default: 'InternshipApplications::WeeklyFramed'
  end
end
