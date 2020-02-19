# frozen_string_literal: true

class AddAlertedForSchoolWeeksToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :missing_school_weeks, foreign_key: { to_table: :schools }, index: true
    add_column :schools, :missing_school_weeks_count, :integer, default: 0
  end
end
