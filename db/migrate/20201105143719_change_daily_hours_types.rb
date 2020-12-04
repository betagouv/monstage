class ChangeDailyHoursTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :new_daily_hours, :jsonb, default: {}
    add_column :internship_offer_infos, :new_daily_hours, :jsonb, default: {}
    add_column :internship_agreements, :new_daily_hours, :jsonb, default: {}
  end
end
