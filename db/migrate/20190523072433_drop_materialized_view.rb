# frozen_string_literal: true

class DropMaterializedView < ActiveRecord::Migration[5.2]
  def change
    remove_index :reporting_internship_offers, :sector_name
    remove_index :reporting_internship_offers, :publicly_name
    # REMOVED because scenic gem is gone
    # drop_view :reporting_internship_offers, materialized: true
    add_index :internship_offers, :department
    add_index :internship_offers, :group_name
  end
end
