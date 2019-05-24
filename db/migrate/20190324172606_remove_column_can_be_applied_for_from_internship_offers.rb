# frozen_string_literal: true

class RemoveColumnCanBeAppliedForFromInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    remove_column :internship_offers, :can_be_applied_for
  end
end
