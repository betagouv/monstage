class AddLunchBreakToInternshipAgreements < ActiveRecord::Migration[6.1]
  def change
    add_column :internship_offer_infos, :daily_lunch_break, :jsonb, default: {}
    add_column :internship_offer_infos, :weekly_lunch_break, :text
    add_column :internship_agreements, :daily_lunch_break, :jsonb, default: {}
    add_column :internship_agreements, :weekly_lunch_break, :text
    add_column :internship_offers, :daily_lunch_break, :jsonb, default: {}
    add_column :internship_offers, :weekly_lunch_break, :text
  end
end
