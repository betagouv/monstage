class AddRemainingPlacesToInternshipOffer < ActiveRecord::Migration[7.0]
  def up
    add_column :internship_offers, :remaining_seats_count, :integer, default: 0
    add_column :internship_offer_infos, :remaining_seats_count, :integer, default: 0
  end

  def down
    remove_column :internship_offer_infos, :remaining_seats_count
    remove_column :internship_offers, :remaining_seats_count
  end
end
