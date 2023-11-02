class AddLunchBreakToPracticalInfos < ActiveRecord::Migration[7.0]
  def change
    add_column :practical_infos, :lunch_break, :text
    add_column :internship_offers, :lunch_break, :text
    add_column :internship_agreements, :lunch_break, :text
  end
end
