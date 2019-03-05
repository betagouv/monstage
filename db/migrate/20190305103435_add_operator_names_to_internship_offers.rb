class AddOperatorNamesToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :operator_names, :string, array: true
    remove_column :internship_offers, :operator_id
  end
end
