class AddMissingIndexesOnInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_index :internship_offers, :published_at
  end
end
