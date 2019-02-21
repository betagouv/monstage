class AddUserRefToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_reference :internship_offers, :operator, foreign_key: { to_table: :users }
  end
end
