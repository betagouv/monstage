class CreateApplicationTrackings < ActiveRecord::Migration[7.0]
  def change
    create_table :application_trackings do |t|
      t.references :internship_offer, null: false
      t.references :student, null: true, foreign_key: { to_table: :users }
      t.references :operator, null: false, foreign_key: { to_table: :users }
      t.datetime :application_submitted_at
      t.datetime :application_approved_at
      t.string :student_generated_id, limit: 150, null: true
      t.integer :remote_status, null: false, default: 5

      t.timestamps
    end

    add_index :application_trackings,
              %i[internship_offer_id student_id student_generated_id],
              unique: true,
              name: 'idx_remote_student'
  end
end
