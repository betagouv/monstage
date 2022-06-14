# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOfferInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include InternshipOfferInfoFormFiller

  test 'can create InternshipOfferInfos::WeeklyFramed' do
    sector = create(:sector)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOfferInfos::WeeklyFramed.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
        fill_in_internship_offer_info_form(sector: sector,
                                           weeks: available_weeks)
        page.assert_no_selector('span.number', text: '1')
        find('span.number', text: '2')
        find('span.number', text: '3')
        click_on "Suivant"
        find('label', text: 'Nom du tuteur/trice')
      end
    end
  end

  test 'employer can see which week is choosen by nearby schools in stepper' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    week_with_school = Week.find_by(number: 10, year: 2019)
    week_without_school = Week.find_by(number: 11, year: 2019)
    create(:school, weeks: [week_with_school])

    sign_in(employer)

    travel_to(Date.new(2019, 3, 1)) do
      visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
      find('label[for="all_year_long"]').click
      find(".bg-success-20[data-week-id='#{week_with_school.id}']")
      find(".bg-dark-70[data-week-id='#{week_without_school.id}']")
    end
  end

  test 'create internship offer info fails gracefuly' do
    sector = create(:sector)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    travel_to(Date.new(2019, 3, 1)) do
      visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
      fill_in_internship_offer_info_form(sector: sector,
                                         weeks: available_weeks)
      as = 'a' * 151
      fill_in 'internship_offer_info_title', with: as
      click_on "Suivant"
      find('#error_explanation')
    end
  end
end
