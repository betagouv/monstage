# frozen_string_literal: true

class AddEmployerDescriptionToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :employer_description, :string
  end
end
