class CreateUsersInternshipOffersHistory < ActiveRecord::Migration[7.0]
  def change
    create_table :users_internship_offers_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :internship_offer, null: false, foreign_key: true
      t.integer :application_clicks, default: 0

      t.timestamps
    end
  end
end
