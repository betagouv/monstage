class AddSiretToOrganisation < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :siret, :string
    add_column :organisations, :is_paqte, :boolean
    add_column :internship_offers, :siret, :string
  end
end
