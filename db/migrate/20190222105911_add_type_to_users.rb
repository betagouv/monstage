# frozen_string_literal: true

class AddTypeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :type, :string
  end
end
