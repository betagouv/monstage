class AddDbInterpolatedFieldToSubTables < ActiveRecord::Migration[7.0]
  def up
    add_column :organisations, :db_interpolated, :boolean, default: false
    add_column :internship_offers, :db_interpolated, :boolean, default: false
  end
  
  def down
    remove_column :organisations, :db_interpolated
    remove_column :internship_offers, :db_interpolated
  end
end
