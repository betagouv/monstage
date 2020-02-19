# frozen_string_literal: true

class AddCustomTrackToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :custom_track, :boolean, null: false, default: false
  end
end
