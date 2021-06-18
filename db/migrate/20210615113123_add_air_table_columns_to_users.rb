class AddAirTableColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :operators, :airtable_reporting_enabled, :boolean, default: false

    Operator::AIRTABLE_CREDENTIAL_MAP.keys.each do |operator_name|
      Operator.where(name: operator_name)
              .update_all(airtable_reporting_enabled: true)
    end

  end
end
