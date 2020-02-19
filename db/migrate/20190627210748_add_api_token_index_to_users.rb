# frozen_string_literal: true

class AddApiTokenIndexToUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :api_token
  end
end
