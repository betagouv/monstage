# frozen_string_literal: true

class CreateReportingInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    create_view :reporting_internship_offers
  end
end
