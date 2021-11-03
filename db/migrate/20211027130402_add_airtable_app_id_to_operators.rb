class AddAirtableAppIdToOperators < ActiveRecord::Migration[6.1]
  def change
    add_column :operators, :airtable_app_id, :string
  end
end
