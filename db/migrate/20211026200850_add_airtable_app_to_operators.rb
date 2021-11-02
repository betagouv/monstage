class AddAirtableAppToOperators < ActiveRecord::Migration[6.1]
  def change
    add_column :operators, :airtable_table, :string
  end
end
