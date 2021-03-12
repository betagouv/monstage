class AddArchivedColumnToClassRoom < ActiveRecord::Migration[6.1]
  def up
    add_column :class_rooms, :anonymized, :boolean, default: false
    add_index :class_rooms, :anonymized
  end

  def down
    remove_index :class_rooms, :anonymized
    remove_column :class_rooms, :anonymized
  end
end
