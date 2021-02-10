class UpdateColumnNameMissingSchoolWeeksIdInUser < ActiveRecord::Migration[6.1]
  def up
    rename_column :users, :missing_school_weeks_id, :missing_weeks_school_id
  end
  def down
    rename_column :users, :missing_weeks_school_id, :missing_school_weeks_id
  end
end
