# frozen_string_literal: true

class RemoveEmployerDescriptionAndAddEmployerNameToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    remove_column :internship_offers, :employer_description
    add_column :internship_offers, :employer_name, :string
  end
end
