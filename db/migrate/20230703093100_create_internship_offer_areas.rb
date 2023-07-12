class CreateInternshipOfferAreas < ActiveRecord::Migration[7.0]
  def up
    create_table :internship_offer_areas do |t|
      t.references :employer, polymorphic: true
      t.string :name

      t.timestamps
    end
    TaskManager.new(
      allowed_environments: %w[development test production],
      task_name: 'data_migrations:create_internship_offer_areas',
      arguments: []
    ).play_task_once(run_with_a_job: false)
  end

  def down
    TaskRegister.where(task_name: 'data_migrations:create_internship_offer_areas').destroy_all
    TaskManager.new(allowed_environments: %w[development test production],
                    task_name: 'data_migrations:create_internship_offer_areas'
                ).reset_task_counter
    drop_table :internship_offer_areas
  end
end
