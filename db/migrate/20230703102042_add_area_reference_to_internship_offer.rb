class AddAreaReferenceToInternshipOffer < ActiveRecord::Migration[7.0]
  def up
    add_reference :internship_offers, :internship_offer_area, null: true, foreign_key: true
  end

  def down
    remove_reference :internship_offers, :internship_offer_area, null: true, foreign_key: true
  end
end
