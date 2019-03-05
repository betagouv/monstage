class AddGroupNameToInsternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :group_name, :string
  end
end
