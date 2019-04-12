class AddEmployerTypeToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :employer_type, :string
  end
end
