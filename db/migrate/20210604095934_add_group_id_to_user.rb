class AddGroupIdToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :ministry, null: true
    add_foreign_key :users, :groups, column: :ministry_id
  end
end
