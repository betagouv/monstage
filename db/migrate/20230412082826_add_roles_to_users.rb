class AddRolesToUsers < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'cpe';
      ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'admin_officer';
    SQL
  end

  def down 
    execute <<-SQL
      ALTER TYPE public.user_role REMOVE VALUE 'cpe';
      ALTER TYPE public.user_role REMOVE VALUE 'admin_officer';
    SQL
  end
end
