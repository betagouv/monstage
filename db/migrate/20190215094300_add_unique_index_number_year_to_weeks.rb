# frozen_string_literal: true

class AddUniqueIndexNumberYearToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_index :weeks, %i[number year], unique: true
  end
end
