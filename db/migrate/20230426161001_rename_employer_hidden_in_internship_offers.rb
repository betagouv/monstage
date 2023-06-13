class RenameEmployerHiddenInInternshipOffers < ActiveRecord::Migration[7.0]
  def change
    rename_column :internship_offers, :employer_hidden, :hidden_duplicate
  end
end
