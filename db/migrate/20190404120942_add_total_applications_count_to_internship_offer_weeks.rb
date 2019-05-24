# frozen_string_literal: true

class AddTotalApplicationsCountToInternshipOfferWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :total_applications_count, :integer, null: false, default: 0
  end
end
