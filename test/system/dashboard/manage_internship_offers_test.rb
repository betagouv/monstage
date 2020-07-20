# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  def wait_form_submitted
    find('.alert-sticky')
  end

  def fill_in_form(sector:, group:, weeks:, school_type:)
    fill_in 'internship_offer_title', with: 'Stage de dev @betagouv.fr ac Brice & Martin'
    find('#internship_offer_description_rich_text', visible: false).set("Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment creer les outils qui feront le monde de demain")
    fill_in 'Nom du tuteu/trice', with: 'Brice Durand'
    fill_in 'Adresse électronique (ex : mon@exemple.fr)', with: 'le@brice.durand'
    fill_in 'Téléphone (ex : 06 12 34 56 78)', with: '0639693969'
    fill_in "Nom de la structure ou du service proposant l'offre", with: 'BetaGouv'
    find('#internship_offer_employer_description_rich_text', visible: false).set("On fait des startup d'état qui déchirent")
    fill_in 'Site web (facultatif)', with: 'https://beta.gouv.fr/'
    find('label', text: 'public').click
    if sector
     select sector.name, from: 'internship_offer_sector_id'
    end
    if school_type
      select I18n.t("activerecord.attributes.internship_offer.internship_type.#{school_type}"),
             from: 'internship_offer_type'
    end
    if group
      select group.name, from: 'internship_offer_group_id'
    end
    if weeks.size.positive?
      find('label[for="all_year_long"]').click
      weeks.map do |week|
        find(:css, "label[for=internship_offer_week_ids_#{week.id}]").click
      end
    end

    find("#internship_offer_autocomplete").fill_in(with: 'Paris, 13eme')
    find('#test-input-full-address #downshift-2-item-0').click
    fill_in "Rue ou compléments d'adresse", with: "La rue qui existe pas dans l'API / OSM"
  end

  test 'can create InternshipOffers::WeeklyFramed' do
    schools = [create(:school), create(:school)]
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOffers::WeeklyFramed.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_form(sector: sectors.first,
                     school_type: :middle_school,
                     group: group,
                     weeks: available_weeks)
        click_on "Enregistrer et publier l'offre"
        wait_form_submitted
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
  end

  test 'can create InternshipOffers::FreeDate' do
    schools = [create(:school), create(:school)]
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOffers::FreeDate.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in_form(sector: sectors.first,
                     school_type: :high_school,
                     group: group,
                     weeks: [])
        click_on "Enregistrer et publier l'offre"
        wait_form_submitted
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
  end

  test 'can edit internship offer' do
    employer = create(:employer)
    internship_offers = [
      create(:weekly_internship_offer, employer: employer,
                                       description_rich_text: 'boucher'),
      create(:free_date_internship_offer, employer:employer,
                                          description_rich_text: 'boucher')
    ]
    sign_in(employer)

    internship_offers.each do |internship_offer|
      visit edit_dashboard_internship_offer_path(internship_offer)
      fill_in 'internship_offer_title', with: 'editok'
      click_on "Enregistrer et publier l'offre"
      wait_form_submitted
      assert_equal 'editok', internship_offer.reload.title
    end
  end

  test 'can discard internship_offer' do
    employer = create(:employer)
    internship_offers = [
      create(:weekly_internship_offer, employer: employer),
      create(:free_date_internship_offer, employer:employer)
    ]
    sign_in(employer)

    internship_offers.each do |internship_offer|
      visit dashboard_internship_offer_path(internship_offer)
      assert_changes -> { internship_offer.reload.discarded_at } do
        page.find('a[data-target="#discard-internship-offer-modal"]').click
        page.find("#discard-internship-offer-modal .btn-primary").click
      end
    end
  end

  test 'can publish/unpublish internship_offer' do
    employer = create(:employer)
    internship_offers = [
      create(:weekly_internship_offer, employer: employer),
      create(:free_date_internship_offer, employer:employer)
    ]
    sign_in(employer)

    internship_offers.each do |internship_offer|
      visit dashboard_internship_offer_path(internship_offer)
      assert_changes -> { internship_offer.reload.published_at } do
        page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
        wait_form_submitted
        assert_nil internship_offer.reload.published_at,'fail to unpublish'
        freeze_time do
          page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
          wait_form_submitted
          assert_equal Time.now, internship_offer.reload.published_at,'fail to republish'
        end
      end
    end
  end

  test 'fails gracefuly' do
    sector = create(:sector)
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019)]
    travel_to(Date.new(2019, 3, 1)) do
      visit employer.custom_dashboard_path
      find('#test-create-offer').click
      fill_in_form(
        sector: sector,
        group: group,
        weeks: available_weeks,
        school_type: :middle_school
      )
      fill_in 'internship_offer_title', with: 'a' * 501
      click_on "Enregistrer et publier l'offre"
      find("#error_explanation")
    end
  end
end
