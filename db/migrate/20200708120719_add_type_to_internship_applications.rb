class AddTypeToInternshipApplications < ActiveRecord::Migration[6.0]
  def up
    add_column :internship_applications, :type, :string, default: 'InternshipApplications::WeeklyFramedApplication'
  end

  def down
    remove_column :internship_applications, :type
  end
end
