class CreateOperatorActivities < ActiveRecord::Migration[7.0]
  def up
    create_table :operator_activities do |t|
      t.references :student, foreign_key: { to_table: :users }
      t.references :internship_offer, null: true, foreign_key: true
      t.integer :operator_id, foreign_key: { to_table: :operators }
      t.boolean :account_created, null: true
      t.boolean :internship_offer_viewed, null: true
      t.boolean :internship_application_sent, null: true
      t.boolean :internship_application_accepted, null: true

      t.timestamps
    end
  end

  def down
    drop_table :operator_activities
  end
end
