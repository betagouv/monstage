class AddGroupToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_reference :internship_offers, :group, null: true, foreign_key: true
  end
end
