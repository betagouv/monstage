class AddDiscardedAtToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :discarded_at, :datetime
    add_index :internship_offers, :discarded_at
  end
end
