class AddLocationToInternshipOffer < ActiveRecord::Migration[7.0]
  def up
    add_column :internship_offers,
               :location_manual_enter,
               :string,
               default: 'from migration',
               null: false,
               limit: 30
    TaskManager.new(
      allowed_environments: %w[all],
      task_name: 'migrations:set_location_manual_enter_for_api_offers'
    ).play_task_once(run_with_a_job: false)
  end

  def down
    remove_column :internship_offers,
                  :location_manual_enter
  end
end
