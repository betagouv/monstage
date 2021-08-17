class AddSirenToOrganisation < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :siren, :string
    add_column :internship_offers, :siren, :string
  end
end
