class TestTaskRegister < ActiveRecord::Migration[7.0]
  def change
    TaskManager.new(
      allowed_environments: %w[development test],
      task_name: 'say_something',
      arguments: ['once_str, only_str']
    ).play_task_once(run_with_a_job: true)

    # TaskManager.new(
    #   allowed_environments: %w[staging test],
    #   task_name: 'say_something'
    # ).play_task_each_time

    # TaskManager.new(
    #   allowed_environments: %w[staging],
    #   task_name: 'say_something_true', # this task does not exist
    #   arguments: ['balzac']
    # ).play_task_once
  end
end
