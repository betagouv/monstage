class RemoveEmployerTypeColumnFromInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    remove_column :internship_offers, :employer_type
  end
end
