class RemoveAirTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :air_table_records
    remove_column :operators, :airtable_id
    remove_column :operators, :airtable_link
    remove_column :operators, :airtable_reporting_enabled
    remove_column :operators, :airtable_table
    remove_column :operators, :airtable_app_id
    add_column :operators, :realized_count, :json, default: {}
  end
end
