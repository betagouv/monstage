class CreateAirTableRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :air_table_records do |t|
      t.text :school_name
      t.text :organisation_name
      t.text :department_name
      t.text :sector_name
      t.boolean :is_public
      t.integer :nb_spot_available, default: 0
      t.integer :nb_spot_used, default: 0
      t.integer :nb_spot_male, default: 0
      t.integer :nb_spot_female, default: 0
      t.text :school_track
      t.text :internship_offer_type
      t.text :comment

      t.timestamps
    end
  end
end
