class AddGroupToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    rename_column :internship_offers, :group, :old_group
    add_reference :internship_offers, :group, null: true, foreign_key: true
  end
end
