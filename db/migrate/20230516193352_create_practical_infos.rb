class CreatePracticalInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :practical_infos do |t|
      t.integer :employer_id
      t.string :street, null: false
      t.string :zipcode, null: false
      t.string :city, null: false
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist
      t.string :department, null: false, default: ''
      t.jsonb :daily_hours, default: {}
      t.jsonb :daily_lunch_break, default: {}
      t.text :weekly_hours, array: true, default: []
      t.text :weekly_lunch_break

      t.timestamps
    end
  end
end
