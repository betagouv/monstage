class AddOrganisationToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_reference :internship_offers, :organisation, index: true
    add_reference :internship_offers, :mentor, index: true
  end
end
