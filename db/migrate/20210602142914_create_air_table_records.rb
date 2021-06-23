class CreateAirTableRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :air_table_records do |t|
      t.text :remote_id

      t.boolean :is_public
      t.integer :nb_spot_available, default: 0
      t.integer :nb_spot_used, default: 0
      t.integer :nb_spot_male, default: 0
      t.integer :nb_spot_female, default: 0
      t.text :department_name
      t.text :school_track
      t.text :internship_offer_type
      t.text :comment

      t.bigint :school_id
      t.bigint :group_id
      t.bigint :sector_id
      t.references :week
      t.references :operator
      t.text :created_by

      t.timestamps
    end
  end
end
