class AddSiretNumberToOrganisation < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :siret, :string
    add_column :organisations, :is_paqte, :boolean
    change_column :organisations, :employer_id, :integer, null: true

    add_index :organisations, :siret, unique: true
  end
end
