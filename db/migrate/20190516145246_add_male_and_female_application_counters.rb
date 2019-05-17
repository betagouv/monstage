class AddMaleAndFemaleApplicationCounters < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :total_female_applications_count, :integer, null: false, default: 0
    add_column :internship_offers, :total_male_applications_count, :integer, null: false, default: 0
  end
end
