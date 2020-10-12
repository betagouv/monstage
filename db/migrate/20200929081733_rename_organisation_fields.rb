class RenameOrganisationFields < ActiveRecord::Migration[6.0]
  def change
    rename_column :organisations, :name, :employer_name
    rename_column :organisations, :description, :employer_description
    rename_column :organisations, :website, :employer_website
  end
end
