class TestTaskRegister < ActiveRecord::Migration[7.0]
  def change
    tm = TaskManager.new(
      allowed_environments: %w[development test],
      task_name: 'say_something',
      arguments: ['once_str, only_str']
    ).play_task_once(no_job: true)

    tm = TaskManager.new(
      allowed_environments: %w[staging test],
      task_name: 'say_something'
    ).play_task_each_time

    tm = TaskManager.new(
      allowed_environments: %w[staging],
      task_name: 'say_something_true', # this task does not exist
      arguments: ['balzac']
    )
    tm.play_task_once
  end
end
