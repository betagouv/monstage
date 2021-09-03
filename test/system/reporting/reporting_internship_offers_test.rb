# frozen_string_literal: true

require 'application_system_test_case'
class ReportingInternshipOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @statistician = create(:statistician)
    @department = @statistician.department
    @sector_agri = create(:sector, name: 'Agriculture')
    @sector_wood = create(:sector, name: 'Filière bois')
    @internship_offer_agri_1 = create(
      :weekly_internship_offer,
      zipcode: 60,
      sector: @sector_agri,
      max_candidates: 1,
      department: @department
    )
    @internship_offer_wood = create(
      :troisieme_segpa_internship_offer,
      zipcode: 60,
      sector: @sector_wood,
      max_candidates: 10,
      department: @department
    )
  end

  test 'Offer reporting can be filtered by school_track' do
    sign_in(@statistician)

    visit reporting_internship_offers_path(department: @department)
    page.first('td.align-middle.bl-1.bc-light.text-blue.text-bigger.font-weight-bold.test-total-report', text: "11")

    select '3ème'
    page.first('td.align-middle.bl-1.bc-light.text-blue.text-bigger.font-weight-bold.test-total-report', text: "1")

    select '3e SEGPA'
    page.first('td.align-middle.bl-1.bc-light.text-blue.text-bigger.font-weight-bold.test-total-report', text: "10")
  end
end
