# frozen_string_literal: true

class SetPublishedAtOnInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    InternshipOffer.all.each do |internship_offer|
      internship_offer.update_column(:published_at, internship_offer.created_at)
    end
  end
end
