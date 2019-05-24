# frozen_string_literal: true

class RemoveSupervisorEmailFromInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    remove_column :internship_offers, :supervisor_email
  end
end
