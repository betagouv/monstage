class RemoveWeeklyFramed < ActiveRecord::Migration[7.0]
  def change
    remove_column :internship_applications, :type
  end
end
