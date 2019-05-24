# frozen_string_literal: true

class AddEmployerIdToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :employer_id, :bigint
    add_foreign_key :internship_offers, :users, column: :employer_id, primary_key: :id
  end
end
