class AddViewCountToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :view_count, :integer, default: 0, null: false
  end
end
