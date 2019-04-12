class AddOperatorIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :operator_id, :bigint, null: true
    add_foreign_key :users, :operators
  end
end
