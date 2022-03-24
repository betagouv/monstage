# frozen_string_literal: true

require 'application_system_test_case'

class ReportingEnterpriseOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'Offer reporting can be filtered by school_track' do
    statistician = create(:statistician) # Oise is the department
    department = statistician.department
    public_internship_offer_0 = create(
      :weekly_internship_offer,
      max_candidates: 100,
      max_students_per_group: 100,
      zipcode: 75012 # Paris
    )
    public_internship_offer = create(
      :weekly_internship_offer, # public internship by default
      zipcode: 60580 # this zipcode belongs to Oise
    ) # 1 public Oise
    private_paqte_internship_offer = create(
      :weekly_internship_offer,
      :with_private_employer_group,
      max_candidates: 10,
      max_students_per_group: 10,
      zipcode: 60580
    ) # 10 paqte(private) Oise
    private_internship_offer_no_group = create(
      :weekly_internship_offer,
      is_public: false,
      group: nil,
      max_candidates: 20,
      max_students_per_group: 20,
      zipcode: 60580
    ) # 20 private Oise --> 30 to go as private
    sign_in(statistician)

    visit reporting_dashboards_path(department: department)
    click_link 'Entreprises'

    public_internship_offer_selector           = ".test-published-offers-#{public_internship_offer.group.id}"
    private_paqte_internship_offer_selector    = ".test-published-offers-#{private_paqte_internship_offer.group.id}"
    private_internship_offer_no_group_selector = ".test-published-offers-"

    select('Secteur Public')
    page.first(public_internship_offer_selector, text: "1")

    select('Secteur Privé (dont Sign. PaQte)')
    page.first(private_paqte_internship_offer_selector, text: "10")
    page.find(private_internship_offer_no_group_selector, text: "20")

    select('Sign. PaQte')
    page.find(private_paqte_internship_offer_selector, text: "10")
  end
end
