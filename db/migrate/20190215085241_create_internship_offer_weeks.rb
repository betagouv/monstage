# frozen_string_literal: true

class CreateInternshipOfferWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :internship_offer_weeks do |t|
      t.belongs_to :internship_offer, foreign_key: true
      t.belongs_to :week, foreign_key: true

      t.timestamps
    end
  end
end
