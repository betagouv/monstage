# frozen_string_literal: true

class CreateClassRooms < ActiveRecord::Migration[5.2]
  def change
    create_table :class_rooms do |t|
      t.string :name
      t.references :school

      t.timestamps
    end
    add_foreign_key :class_rooms, :schools
  end
end
