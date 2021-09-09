class RemoveColumnMissingSchoolWeeksColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :missing_weeks_school_id
    remove_column :schools, :missing_school_weeks_count
  end
end
