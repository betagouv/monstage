class AddAreaReferenceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :current_area, foreign_key: { to_table: :internship_offer_areas }
  end
end
