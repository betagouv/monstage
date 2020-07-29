class AddInternshipOfferIdToInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    add_reference :internship_applications, :internship_offer, foreign_key: { to_table: :internship_offers }, index: true
  end
end
