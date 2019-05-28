# frozen_string_literal: true

class CreateReportingInternshipOffersV2s < ActiveRecord::Migration[5.2]
  def up
    # drop_view :reporting_internship_offers
    # create_view :reporting_internship_offers, materialized: true
  end

  def down
    # drop_view :reporting_internship_offers
    # create_view :reporting_internship_offers
  end
end
