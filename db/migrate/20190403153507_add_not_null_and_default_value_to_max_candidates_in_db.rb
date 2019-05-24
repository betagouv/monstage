# frozen_string_literal: true

class AddNotNullAndDefaultValueToMaxCandidatesInDb < ActiveRecord::Migration[5.2]
  def change
    change_column :internship_offers, :max_candidates, :integer, null: false, default: 1
  end
end
