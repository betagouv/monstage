class RemoveOutdatedColumnsFromSectors < ActiveRecord::Migration[5.2]
  def up
    remove_column :sectors, :publication_name
    remove_column :sectors, :custom_name
    remove_column :sectors, :slug
  end
  def down
    add_column :sectors, :publication_name, :string
    add_column :sectors, :custom_name, :string
    add_column :sectors, :slug, :string
  end
end
