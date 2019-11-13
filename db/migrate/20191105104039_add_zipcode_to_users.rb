class AddZipcodeToUsers < ActiveRecord::Migration[6.0]
  def up
    add_column :users, :department_name, :string
  end
end
