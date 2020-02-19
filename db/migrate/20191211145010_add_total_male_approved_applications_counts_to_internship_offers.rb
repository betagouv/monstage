# frozen_string_literal: true

class AddTotalMaleApprovedApplicationsCountsToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :total_male_approved_applications_count, :integer, default: 0
    add_column :internship_offers, :total_custom_track_approved_applications_count, :integer, default: 0
  end
end
