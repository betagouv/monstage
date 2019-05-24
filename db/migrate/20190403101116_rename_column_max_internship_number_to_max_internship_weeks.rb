# frozen_string_literal: true

class RenameColumnMaxInternshipNumberToMaxInternshipWeeks < ActiveRecord::Migration[5.2]
  def change
    rename_column :internship_offers, :max_internship_number, :max_internship_week_number
  end
end
