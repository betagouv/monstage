class RenameMaxWeeksToMaxInternshipNumber < ActiveRecord::Migration[5.2]
  def change
    rename_column :internship_offers, :max_weeks, :max_internship_number
  end
end
