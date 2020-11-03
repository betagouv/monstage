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
        fill_in_internship_offer_info_form(school_track: :troisieme_generale,
                                           sector: sector,
                                           weeks: available_weeks)

        click_on "Suivant"
        find('label', text: 'Nom du tuteur/trice')
      end
    end
  end

  test 'can create InternshipOfferInfos::FreeDate' do
    sector = create(:sector)
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOfferInfos::FreeDate.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
        fill_in_internship_offer_info_form(school_track: :bac_pro,
                                           sector: sector,
                                           weeks: available_weeks)
        click_on "Suivant"
        find('label', text: 'Nom du tuteur/trice')
      end
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
      fill_in_internship_offer_info_form(school_track: :troisieme_generale,
                                         sector: sector,
                                         weeks: available_weeks)
      as = 'a' * 151
      fill_in 'internship_offer_info_title', with: as
      click_on "Suivant"
      find('#error_explanation')
    end
  end
end
