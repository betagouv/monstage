class AddIndexOnInternshipOfferType < ActiveRecord::Migration[6.0]
  def change
    add_index :internship_offers, :type
  end
end
