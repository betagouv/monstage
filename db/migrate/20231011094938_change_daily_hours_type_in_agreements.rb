class ChangeDailyHoursTypeInAgreements < ActiveRecord::Migration[7.0]
  def up
    TaskManager.new(
      allowed_environments: %w[development review test staging production],
      task_name: 'data_migrations:fill_daily_hours_in_internship_agreements',
      arguments: []
    ).play_task_each_time(run_with_a_job: false)
    remove_column :internship_agreements, :daily_hours
    rename_column :internship_agreements, :new_daily_hours, :daily_hours
  end

  def down
    rename_column :internship_agreements, :daily_hours, :new_daily_hours
    add_column :internship_agreements, :daily_hours, :text, array: true, default: []
  end
end
