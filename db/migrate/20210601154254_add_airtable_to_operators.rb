class AddAirtableToOperators < ActiveRecord::Migration[6.1]
  def change
    add_column :operators, :airtable_id, :string
    add_column :operators, :airtable_link, :string
  end
end
