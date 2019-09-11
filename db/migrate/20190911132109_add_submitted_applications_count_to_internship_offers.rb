class AddSubmittedApplicationsCountToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :submitted_applications_count, :integer, default: 0, null: false
    add_column :internship_offers, :rejected_applications_count, :integer, default: 0, null: false
    Services::CounterManager.reset_internship_offer_counters
  end
end
