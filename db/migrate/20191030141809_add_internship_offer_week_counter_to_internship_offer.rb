class AddInternshipOfferWeekCounterToInternshipOffer < ActiveRecord::Migration[6.0]
  def up
    remove_index :internship_offers, name: 'not_blocked_by_weeks_count_index'
    rename_column :internship_offers, :max_occurence, :internship_offer_weeks_count
    add_index :internship_offers, %i[internship_offer_weeks_count blocked_weeks_count], name: 'not_blocked_by_weeks_count_index'
  end

  def down
    remove_index :internship_offers, name: 'not_blocked_by_weeks_count_index'
    rename_column :internship_offers, :internship_offer_weeks_count, :max_occurence
    add_index :internship_offers, %i[max_occurence blocked_weeks_count], name: 'not_blocked_by_weeks_count_index'
  end
end
