class AddEmployerHiddenFieldToIntershipOffer < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_offers, :employer_hidden, :boolean, default: false
  end
end
