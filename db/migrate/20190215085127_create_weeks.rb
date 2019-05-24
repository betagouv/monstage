# frozen_string_literal: true

class CreateWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :weeks do |t|
      t.integer :week
      t.integer :year

      t.timestamps
    end
  end
end
