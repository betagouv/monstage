class AddMissingIndexesOnMaxCandidatesOrWeeksReached < ActiveRecord::Migration[5.2]
  def change
    add_index :internship_offers, [:max_weeks, :blocked_weeks_count]
    add_index :internship_offer_weeks, :blocked_applications_count
    add_index :internship_applications, :aasm_state
  end
end
