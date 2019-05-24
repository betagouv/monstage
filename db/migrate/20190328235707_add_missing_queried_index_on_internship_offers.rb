# frozen_string_literal: true

class AddMissingQueriedIndexOnInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_index :internship_offers, :employer_id
    add_index :internship_offers, :school_id
  end
end
