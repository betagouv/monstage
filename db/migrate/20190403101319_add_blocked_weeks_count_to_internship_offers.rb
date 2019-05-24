# frozen_string_literal: true

class AddBlockedWeeksCountToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :blocked_weeks_count, :integer, default: 0, null: false
  end
end
