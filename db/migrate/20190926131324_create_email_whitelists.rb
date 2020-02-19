# frozen_string_literal: true

class CreateEmailWhitelists < ActiveRecord::Migration[6.0]
  def change
    create_table :email_whitelists do |t|
      t.string :email
      t.string :zipcode

      t.timestamps
    end

    Credentials.enc(:statisticians, prefix_env: false).inject({}) do |_accu, (zipcode, emails)|
      emails.map do |email|
        EmailWhitelist.create!(email: email, zipcode: zipcode)
      end
    end
  end
end
