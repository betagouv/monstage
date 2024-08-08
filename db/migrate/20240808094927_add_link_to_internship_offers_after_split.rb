class AddLinkToInternshipOffersAfterSplit < ActiveRecord::Migration[7.1]
  def up
    add_column :internship_offers, :mother_id, :integer, default: 0
  end

  def down
    remove_column :internship_offers, :mother_id
  end
end
