class AddColumnRoleToUsers < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE user_role AS ENUM ('school_manager', 'teacher', 'main_teacher', 'other' );
    SQL
    add_column :users, :role, :user_role
  end

  def down
    add_column :users, :role
    execute <<-SQL
      DROP TYPE user_role;
    SQL
  end
end
