class AddAasmToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :aasm_state, :string
  end
end
