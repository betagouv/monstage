class MoveEmployerReferenceFromInternshipOfferToAreas < ActiveRecord::Migration[7.0]
  def up
    TaskManager.new(allowed_environments: %w[development test production],
      task_name: 'data_migrations:add_area_reference_to_internship_offer',
      arguments: []
    ).play_task_each_time(run_with_a_job: false)
    TaskManager.new(allowed_environments: %w[development test production],
                    task_name: 'data_migrations:add_employer_reference_to_internship_offer')
                .reset_task_counter
    TaskManager.new(allowed_environments: %w[development test production],
      task_name: 'data_migrations:check_every_employer_has_its_space_and_references',
      arguments: []
    ).play_task_each_time(run_with_a_job: false)
  end

  def down
    TaskManager.new(
      allowed_environments: %w[development test production],
      task_name: 'data_migrations:add_employer_reference_to_internship_offer',
      arguments: []
    ).play_task_once(run_with_a_job: false)
    TaskManager.new(allowed_environments: %w[development test production],
                    task_name: 'data_migrations:add_area_reference_to_internship_offer')
               .reset_task_counter
  end
end
