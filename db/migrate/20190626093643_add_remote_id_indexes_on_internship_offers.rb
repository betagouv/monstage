# frozen_string_literal: true

class AddRemoteIdIndexesOnInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_index :internship_offers, :remote_id
  end
end
