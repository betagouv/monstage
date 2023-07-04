class DataMigrationForEmployerIdInInternshipOffers < ActiveRecord::Migration[7.0]
  def up
    TaskManager.new(
      allowed_environments: %w[development test production],
      task_name: 'data_migrations:add_area_reference_to_internship_offer',
      arguments: []
    ).play_task_once(run_with_a_job: true)
  end

  def down
    TaskRegister.where(task_name: 'data_migrations:add_area_reference_to_internship_offer')
                .destroy_all
  end
end
