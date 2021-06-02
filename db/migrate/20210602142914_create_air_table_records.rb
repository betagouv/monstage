class CreateAirTableRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :air_table_records do |t|
      t.text :school_name
      t.text :organisation_name
      t.text :department_name
      t.text :sector_name
      t.boolean :is_public
      t.integer :nb_spot_available
      t.integer :nb_spot_used
      t.integer :nb_spot_male
      t.integer :nb_spot_female
      t.text :school_track
      t.text :internship_offer_type
      t.text :comment

      t.timestamps
    end
  end
end
