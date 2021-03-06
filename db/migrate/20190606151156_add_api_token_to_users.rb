# frozen_string_literal: true

class AddApiTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_token, :string
    Users::Operator.where(api_token: nil).all do |operator|
      operator.api_token = SecureRandom.uuid
      operator.save
    end
  end
end
