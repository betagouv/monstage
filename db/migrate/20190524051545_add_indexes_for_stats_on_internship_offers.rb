# frozen_string_literal: true

class AddIndexesForStatsOnInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_index :internship_offers, :academy
  end
end
