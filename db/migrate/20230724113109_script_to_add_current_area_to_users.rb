class ScriptToAddCurrentAreaToUsers < ActiveRecord::Migration[7.0]
  def up
    TaskManager.new(allowed_environments: %w[development test staging production],
                    task_name: 'data_migrations:add_area_reference_to_users',
                    arguments: []
                   ).play_task_each_time(run_with_a_job: false)
  end
  
  def down
  end
end
