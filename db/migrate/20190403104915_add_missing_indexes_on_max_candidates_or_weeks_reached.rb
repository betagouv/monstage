# frozen_string_literal: true

class AddMissingIndexesOnMaxCandidatesOrWeeksReached < ActiveRecord::Migration[5.2]
  # add_index :internship_offers, [:max_occurence, :blocked_weeks_count],
  #                                 name: 'not_blocked_by_weeks_count_index'
  def change
    add_index :internship_offers, %i[max_occurence blocked_weeks_count],
              name: 'not_blocked_by_weeks_count_index'
    add_index :internship_offer_weeks, :blocked_applications_count
    add_index :internship_applications, :aasm_state
  end
end
