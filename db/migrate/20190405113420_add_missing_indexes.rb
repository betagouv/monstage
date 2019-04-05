class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :internship_offer_weeks, :approved_applications_count
  end
end
