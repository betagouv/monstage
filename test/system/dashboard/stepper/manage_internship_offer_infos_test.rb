# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOfferInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include InternshipOfferInfoFormFiller

  test 'can create InternshipOfferInfo' do
    sector = create(:sector)
    employer = create(:employer)
    school_name = 'Abd El Kader'
    organisation = create(:organisation, employer: employer)
    school = create(:school, city: 'Paris', zipcode: 75012, name: school_name)
    sign_in(employer)
    assert_difference 'InternshipOfferInfo.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
        fill_in_internship_offer_info_form(sector: sector)
        page.assert_no_selector('span.number', text: '1')
        find('span', text: 'Étape 2 sur 5')
        click_on "Suivant"
        find('h2', text: 'Accueil des élèves')
      end
    end
  end

  test 'create internship offer info fails gracefuly' do
    sector = create(:sector)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    sign_in(employer)
    travel_to(Date.new(2019, 3, 1)) do
      visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
      fill_in_internship_offer_info_form(sector: sector)
      as = 'a' * 151
      fill_in 'internship_offer_info_title', with: as
      click_on "Suivant"
      find('.fr-alert.fr-alert--error')
    end
  end

  test 'employer can create an offer on May 31st for next year' do
    travel_to Date.new(2023, 5, 29) do
      sector = create(:sector)
      employer = create(:employer)
      school_name = 'Abd El Kader'
      organisation = create(:organisation, employer: employer)
      school = create(:school, city: 'Paris', zipcode: 75012, name: school_name)
      
      sign_in(employer)
      available_weeks = Week.selectable_from_now_until_end_of_school_year
      assert_equal [2023, 2024], available_weeks.map(&:year).uniq
      assert_difference 'InternshipOfferInfo.count' do
        visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
        fill_in_internship_offer_info_form(sector: sector)
        page.assert_no_selector('span.number', text: '1')
        find('span', text: 'Étape 2 sur 5')
        click_on "Suivant"
        find('span', text: 'Étape 3 sur 5')
      end
    end
  end
end
