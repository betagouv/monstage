class UpdateDailyHoursFromInternshipOffers < ActiveRecord::Migration[7.0]
  def change
    remove_column :internship_offers, :daily_hours
    add_column :internship_offers, :daily_hours, :jsonb, using: 'daily_hours::jsonb'
  end
end
