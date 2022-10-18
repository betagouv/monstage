class CreateRemoteUserActivities < ActiveRecord::Migration[7.0]
  def up
    create_table :remote_user_activities do |t|
      t.references :student, foreign_key: { to_table: :users }
      t.references :operator, foreign_key: { to_table: :operators }
      t.references :internship_offer, null: true, foreign_key: true
      t.datetime :account_created_at, null: true
      t.datetime :internship_offer_viewed_at, null: true
      t.datetime :internship_application_sent_at, null: true
      t.datetime :internship_application_accepted_at, null: true

      t.timestamps
    end
  end

  def down
    drop_table :remote_user_activities
  end
end
