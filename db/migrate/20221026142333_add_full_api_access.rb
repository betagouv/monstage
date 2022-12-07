class AddFullApiAccess < ActiveRecord::Migration[7.0]
  def change
    add_column :operators, :api_full_access, :boolean, default: false
  end
end
