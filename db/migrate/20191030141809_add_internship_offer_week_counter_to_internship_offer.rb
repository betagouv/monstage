class AddInternshipOfferWeekCounterToInternshipOffer < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :internship_offer_weeks_count, :integer
  end
end
