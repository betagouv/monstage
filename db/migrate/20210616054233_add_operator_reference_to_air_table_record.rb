class AddOperatorReferenceToAirTableRecord < ActiveRecord::Migration[6.1]
  def change
    add_reference :air_table_records, :operator
  end
end
