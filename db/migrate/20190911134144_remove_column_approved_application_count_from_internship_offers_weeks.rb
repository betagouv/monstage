# frozen_string_literal: true

class RemoveColumnApprovedApplicationCountFromInternshipOffersWeeks < ActiveRecord::Migration[6.0]
  def change
    remove_column :internship_offer_weeks, :approved_applications_count
  end
end
