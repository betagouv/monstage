# frozen_string_literal: true

class AddHandicapToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :handicap, :text
  end
end
