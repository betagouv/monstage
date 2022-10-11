class RemoveAnonymizedToClassRooms < ActiveRecord::Migration[7.0]
  def up
    say_with_time "Suppression de toutes les classes anonymisées." do
      ClassRoom.where("anonymized = ?", true).destroy_all
    end

    remove_index :class_rooms, :anonymized
    remove_column :class_rooms, :anonymized
  end

  def down
    add_column :class_rooms, :anonymized, :boolean, default: false
    add_index :class_rooms, :anonymized
  end
end
