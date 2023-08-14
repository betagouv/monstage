class DataMigrationForEmployerIdInInternshipOffers < ActiveRecord::Migration[7.0]
  def up
    TaskManager.new(
      allowed_environments: %w[development test production staging],
      task_name: 'data_migrations:add_area_reference_to_internship_offer',
      arguments: []
    ).play_task_each_time(run_with_a_job: false)
  end

  def down
    TaskRegister.where(task_name: 'data_migrations:add_area_reference_to_internship_offer')
                .destroy_all
  end
end
