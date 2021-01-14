# frozen_string_literal: true

class CreateGodUser < ActiveRecord::Migration[5.2]
  def up
    God.create!(password: Rails.application.credentials.dig(:god, :password),
                email: Rails.application.credentials.dig(:god, :email),
                confirmed_at: Time.now.utc,
                first_name: 'Super',
                last_name: 'Admin')
  end

  def down
    God.destroy_all
  end
end
