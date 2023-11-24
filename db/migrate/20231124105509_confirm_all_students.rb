class ConfirmAllStudents < ActiveRecord::Migration[7.0]
  def up
    TaskManager.new(allowed_environments: %w[development test production review staging],
      task_name: 'data_migrations:confirm_all_students',
      arguments: []
    ).play_task_each_time(run_with_a_job: false)
  end

  def down 
  end
end
