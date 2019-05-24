# frozen_string_literal: true

class AddClassRoomIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :class_room_id, :bigint
    add_foreign_key :users, :class_rooms, column: :class_room_id, primary_key: :id
  end
end
