class DropTableInternshipOffersOperators < ActiveRecord::Migration[6.0]
  def change
    drop_table :internship_offer_operators
  end
end
