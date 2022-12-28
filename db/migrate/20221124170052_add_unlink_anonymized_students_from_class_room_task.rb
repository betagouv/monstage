class AddUnlinkAnonymizedStudentsFromClassRoomTask < ActiveRecord::Migration[7.0]
  def up
    TaskManager.new(
      allowed_environments: %w[staging production],
      task_name: 'migrations:unlink_anonymized_students_from_class_room'
    ).play_task_once(run_with_a_job: true)
  end

  def down
  end
end
