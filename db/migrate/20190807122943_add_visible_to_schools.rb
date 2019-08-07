class AddVisibleToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :visible, :boolean, default: true
  end
end
