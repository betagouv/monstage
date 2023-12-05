class AddHandicapAccessibleToInternshipOffer < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_offers, :handicap_accessible, :boolean, default: false
    remove_column :users, :handicap
  end
end
