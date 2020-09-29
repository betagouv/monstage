class AddEmployerIdToOrganisations < ActiveRecord::Migration[6.0]
  def change
    Organisation.destroy_all
    add_column :organisations, :employer_id, :bigint, null: false
    add_foreign_key :organisations, :users, column: :employer_id, primary_key: :id
  end
end
