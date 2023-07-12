class AddReferenceToInternshipOffer < ActiveRecord::Migration[7.0]
  def change
    add_reference(:internship_offers, :internship_offer_area, foreign_key: true, null: true)
  end
end
