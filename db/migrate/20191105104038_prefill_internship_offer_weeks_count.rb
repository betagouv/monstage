# frozen_string_literal: true

class PrefillInternshipOfferWeeksCount < ActiveRecord::Migration[6.0]
  def up
    Services::CounterManager.reset_internship_offer_weeks_counter
  end
end
