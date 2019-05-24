class RemoveColumnRegionFromInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    remove_column :internship_offers, :region
  end
end
