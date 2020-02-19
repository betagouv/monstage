# frozen_string_literal: true

class AddYearIndexToWeeks < ActiveRecord::Migration[6.0]
  def change
    add_index :weeks, :year
    add_index :internship_offer_weeks, %i[internship_offer_id week_id]
  end
end
