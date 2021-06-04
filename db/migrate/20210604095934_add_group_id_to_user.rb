class AddGroupIdToUser < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :group_id, :integer
    add_index :users, :group_id
  end

  def down
    remove_index :users, :group_id
    remove_column :users, :group_id
  end
end
