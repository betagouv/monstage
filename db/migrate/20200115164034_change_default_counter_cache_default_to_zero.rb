class ChangeDefaultCounterCacheDefaultToZero < ActiveRecord::Migration[6.0]
  def change
    change_column :internship_offers, :internship_offer_weeks_count, :integer, null: false, default: 0
  end
end
