class AddMissingIndexOnUsersRole < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :role
  end
end
