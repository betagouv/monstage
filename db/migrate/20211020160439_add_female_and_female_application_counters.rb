class AddFemaleAndFemaleApplicationCounters < ActiveRecord::Migration[6.1]
  def change
    add_column :internship_offers, :total_female_applications_count, :integer, null: false, default: 0
    add_column :internship_offers, :total_female_convention_signed_applications_count, :integer, null: false, default: 0
    add_column :internship_offers, :total_female_approved_applications_count, :integer, default: 0
  end
end
