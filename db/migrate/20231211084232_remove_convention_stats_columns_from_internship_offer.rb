class RemoveConventionStatsColumnsFromInternshipOffer < ActiveRecord::Migration[7.1]
  def up
    remove_column :internship_offers, :convention_signed_applications_count
    remove_column :internship_offers, :total_male_convention_signed_applications_count
    remove_column :internship_offers, :total_female_convention_signed_applications_count
  end

  def down
    add_column :internship_offers, :convention_signed_applications_count, :integer, default: 0
    add_column :internship_offers, :total_male_convention_signed_applications_count, :integer, default: 0
    add_column :internship_offers, :total_female_convention_signed_applications_count, :integer, default: 0
  end
end
