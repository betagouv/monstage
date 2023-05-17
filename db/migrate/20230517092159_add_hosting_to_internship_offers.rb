class AddHostingToInternshipOffers < ActiveRecord::Migration[7.0]
  def change
    add_reference :internship_offers, :hosting_info, foreign_key: true
    add_reference :internship_offers, :practical_info, foreign_key: true
  end
end
