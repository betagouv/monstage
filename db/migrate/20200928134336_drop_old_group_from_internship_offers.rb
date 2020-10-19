class DropOldGroupFromInternshipOffers < ActiveRecord::Migration[6.0]
  def up
    remove_column :internship_offers, :old_group
  end
end
