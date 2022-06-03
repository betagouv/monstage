class CreateSignatures < ActiveRecord::Migration[7.0]
  def change
    create_table :signatures do |t|
      t.string :ip_student, limit: 40, null: false
      t.string :ip_employer, limit: 40, null: false
      t.string :ip_school_manager, limit: 40, null: false
      t.datetime :signature_date_employer, null: false
      t.datetime :signature_date_school_manager, null: false
      t.datetime :signature_date_student, null: false
      t.references :internship_agreement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
