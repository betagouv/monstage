class CreateFavoriteInternshipOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.belongs_to :user
      t.belongs_to :internship_offer
    end

    add_index :favorites, [:user_id, :internship_offer_id], unique: true
  end
end
