class AddOrganisationToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_reference :internship_offers, :internship_offer_info, index: true
    add_reference :internship_offers, :organisation, index: true
    add_reference :internship_offers, :mentor, index: true
    add_column :internship_offers, :weekly_hours, :text, array: true, default: []
    add_column :internship_offers, :daily_hours, :text, array: true, default: []
  end
end
