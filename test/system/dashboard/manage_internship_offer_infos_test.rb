# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOfferInfosTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def fill_in_form(sector:, weeks:, school_track:)
    if school_track
      select I18n.t("activerecord.attributes.internship_offer.internship_type.#{school_track}"),
             from: 'internship_offer_info_type'
    end
    fill_in 'internship_offer_info_title', with: 'Stage de dev @betagouv.fr ac Brice & Martin'
    select sector.name, from: 'internship_offer_info_sector_id' if sector
    find('#internship_offer_info_description_rich_text', visible: false).set("Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment creer les outils qui feront le monde de demain")
    find('label', text: 'Individuel').click
    find('label[for="all_year_long"]').click
    
  end

  test 'can create InternshipOfferInfos::WeeklyFramed' do
    schools = [create(:school), create(:school)]
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    organisation = create(:organisation)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOfferInfos::WeeklyFramedInfo.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_internship_offer_info_path(organisation_id: organisation.id)
        fill_in_form(school_track: :middle_school,
                     sector: sectors.first,
                     weeks: available_weeks)
        
        click_on "Suivant"
      end
    end
  end

  test 'can create InternshipOfferInfos::FreeDate' do
    schools = [create(:school), create(:school)]
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    organisation = create(:organisation)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOfferInfos::FreeDateInfo.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_internship_offer_info_path(organisation_id: organisation.id)
        fill_in_form(school_track: :high_school,
                     sector: sectors.first,
                     weeks: available_weeks)
        click_on "Suivant"
      end
    end
  end

  test 'fails gracefuly' do
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    organisation = create(:organisation)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    travel_to(Date.new(2019, 3, 1)) do
      visit new_dashboard_internship_offer_info_path(organisation_id: organisation.id)
      fill_in_form(school_track: :high_school,
        sector: sectors.first,
        weeks: available_weeks)
      as = 'a' * 151
      fill_in 'internship_offer_info_title', with: as
      click_on "Suivant"
      find('#error_explanation')
    end
  end
end
