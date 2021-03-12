class AddArchivedColumnToClassRoom < ActiveRecord::Migration[6.1]
  def up
    add_column :class_rooms, :archived_at, :date, null: true
    add_index :class_rooms, :archived_at
  end
  def down
    remove_index :class_rooms, :archived_at
    remove_column :class_rooms, :archived_at
  end
end
