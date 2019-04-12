class RemoveColumnOperatorNamesFromInternshipOffer < ActiveRecord::Migration[5.2]
  def change
    remove_column :internship_offers, :operator_names
  end
end
