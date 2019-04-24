class AddGfeNamePublicationNameCustomNameToSectors < ActiveRecord::Migration[5.2]
  def change
    add_column :sectors, :gfe_name, :string, null: false, default: ''
    add_column :sectors, :publication_name, :string, default: ''
    add_column :sectors, :custom_name, :string, null: false, default: ''
    add_column :sectors, :slug, :string, null: false, default: ''
  end
end
