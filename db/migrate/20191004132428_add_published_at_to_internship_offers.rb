# frozen_string_literal: true

class AddPublishedAtToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :published_at, :datetime
  end
end
