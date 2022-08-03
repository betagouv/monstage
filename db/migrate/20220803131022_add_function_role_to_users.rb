class AddFunctionRoleToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :employer_role, :string, null: true
  end

  def down
    remove_column :users, :employer_role
  end
end
