class AddWeeklyHoursDailyHoursToInternshipAgreements < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_agreements, :weekly_hours, :text, array: true, default: []
    add_column :internship_agreements, :daily_hours, :text, array: true, default: []
  end
end
