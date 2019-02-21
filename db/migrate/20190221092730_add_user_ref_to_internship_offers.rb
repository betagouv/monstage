class AddUserRefToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_reference :internship_offers, :user, foreign_key: true
  end
end
