class AddRemainingPlacesToInternshipOffer < ActiveRecord::Migration[7.0]
  def up
    add_column :internship_offers, :remaining_places_count, :integer, default: 0
  end

  def down
    remove_column :internship_offers, :remaining_places_count
  end
end
