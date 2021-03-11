class AddArchivedColumnToClassRoom < ActiveRecord::Migration[6.1]
  def up
    add_column :class_rooms, :discarded_at, :datetime, null: true
    add_index :class_rooms, :discarded_at
  end
  def down
    remove_index :class_rooms, :discarded_at
    remove_column :class_rooms, :discarded_at
  end
end
