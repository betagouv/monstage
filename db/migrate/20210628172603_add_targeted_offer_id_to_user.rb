class AddTargetedOfferIdToUser < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :targeted_offer_id, :integer, null: true
  end

  def down
    remove_column :users, :targeted_offer_id
  end
end
