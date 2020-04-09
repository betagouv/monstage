class SetupFtsOnInternshipOffers < ActiveRecord::Migration[6.0]
  def up
    add_column :internship_offers, :search_tsv, :tsvector
    add_index :internship_offers, :search_tsv, using: 'gin'
  end

  def down
    remove_index :internship_offers, :search_tsv
    remove_column :internship_offers, :search_tsv
  end
end
