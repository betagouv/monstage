# frozen_string_literal: true

require 'application_system_test_case'

class ManageInternshipOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  def wait_form_submitted
    find('.alert-sticky')
  end

  # def fill_in_form(sector:, group:, weeks:, school_track:)
  #   fill_in 'internship_offer_title', with: 'Stage de dev @betagouv.fr ac Brice & Martin'
  #   find('#internship_offer_description_rich_text', visible: false).set("Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment creer les outils qui feront le monde de demain")
  #   fill_in 'Nom du tuteu/trice', with: 'Brice Durand'
  #   fill_in 'Adresse électronique (ex : mon@exemple.fr)', with: 'le@brice.durand'
  #   fill_in 'Téléphone (ex : 06 12 34 56 78)', with: '0639693969'
  #   fill_in "Nom de la structure ou du service proposant l'offre", with: 'BetaGouv'
  #   find('#internship_offer_employer_description_rich_text', visible: false).set("On fait des startup d'état qui déchirent")
  #   fill_in 'Site web (facultatif)', with: 'https://beta.gouv.fr/'
  #   find('label', text: 'public').click
  #   select sector.name, from: 'internship_offer_sector_id' if sector
  #   if school_track
  #     select I18n.t("enum.school_tracks.#{school_track}"),
  #            from: 'internship_offer_school_track'
  #     if school_track == :troisieme_generale
  #       page.execute_script(
  #         "document.getElementById('internship_offer_type').value = 'InternshipOffers::WeeklyFramed'"
  #       )
  #     else
  #       page.execute_script(
  #         "document.getElementById('internship_offer_type').value = 'InternshipOffers::FreeDate'"
  #       )
  #     end
  #   end

  #   select group.name, from: 'internship_offer_group_id' if group
  #   if weeks.size.positive?
  #     find('label[for="all_year_long"]').click
  #     weeks.map do |week|
  #       find(:css, "label[for=internship_offer_week_ids_#{week.id}]").click
  #     end
  #   end

  #   find('#internship_offer_autocomplete').fill_in(with: 'Paris, 13eme')
  #   find('#test-input-full-address #downshift-2-item-0').click
  #   fill_in "Rue ou compléments d'adresse", with: "La rue qui existe pas dans l'API / OSM"
  # end

  def fill_in_form
    fill_in 'Nom du tuteur/trice', with: 'Brice Durand'
    fill_in 'Adresse électronique / Email', with: 'le@brice.durand'
    fill_in 'Numéro de téléphone', with: '0639693969'
  end
  
  # test 'can create InternshipOffers::WeeklyFramed' do
  #   schools = [create(:school), create(:school)]
  #   sectors = [create(:sector), create(:sector)]
  #   employer = create(:employer)
  #   group = create(:group, name: 'hello', is_public: true)
  #   sign_in(employer)
  #   available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
  #   assert_difference 'InternshipOffers::WeeklyFramed.count' do
  #     travel_to(Date.new(2019, 3, 1)) do
  #       visit employer.custom_dashboard_path
  #       find('#test-create-offer').click
  #       fill_in_form(sector: sectors.first,
  #                    school_track: :troisieme_generale,
  #                    group: group,
  #                    weeks: available_weeks)
  #       click_on "Enregistrer et publier l'offre"
  #       wait_form_submitted
  #     end
  #   end
  #   assert_equal employer, InternshipOffer.first.employer
  #   assert_equal 'User', InternshipOffer.first.employer_type
  # end

  test 'can create InternshipOffer' do
    employer = create(:employer)
    sign_in(employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:weekly_internship_offer_info,  employer: employer)
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                               internship_offer_info_id: internship_offer_info.id)
        fill_in_form
        click_on "Publier l'offre !"
        wait_form_submitted
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
  end

  test 'can edit internship offer' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    sign_in(employer)
    visit edit_dashboard_internship_offer_path(internship_offer)
    find('input[name="internship_offer[employer_name]"]').fill_in(with: 'NewCompany')

    click_on "Modifier l'offre"
    wait_form_submitted
    assert /NewCompany/.match?(internship_offer.reload.employer_name)
  end

  # test 'can edit school_track of an internship offer back and forth' do
  #   employer = create(:employer)
  #   internship_offer = create(:free_date_internship_offer, employer: employer)
  #   sign_in(employer)

  #   visit edit_dashboard_internship_offer_path(internship_offer)
  #   select '3e générale'
  #   click_on "Enregistrer et publier l'offre"

  #   visit edit_dashboard_internship_offer_path(internship_offer)
  #   select 'Bac pro'
  #   fill_in 'internship_offer_title', with: 'editok'
  #   find('#internship_offer_description_rich_text', visible: false).set("On fait des startup d'état qui déchirent")
  #   click_on "Enregistrer et publier l'offre"
  #   wait_form_submitted
  #   assert_equal 'editok', internship_offer.reload.title
  # end

  test 'can discard internship_offer' do
    employer = create(:employer)
    internship_offers = [
      create(:weekly_internship_offer, employer: employer),
      create(:free_date_internship_offer, employer: employer)
    ]
    sign_in(employer)

    internship_offers.each do |internship_offer|
      visit dashboard_internship_offer_path(internship_offer)
      assert_changes -> { internship_offer.reload.discarded_at } do
        page.find('a[data-target="#discard-internship-offer-modal"]').click
        page.find('#discard-internship-offer-modal .btn-primary').click
      end
    end
  end

  test 'can publish/unpublish internship_offer' do
    employer = create(:employer)
    internship_offers = [
      create(:weekly_internship_offer, employer: employer),
      create(:free_date_internship_offer, employer: employer)
    ]
    sign_in(employer)

    internship_offers.each do |internship_offer|
      visit dashboard_internship_offer_path(internship_offer)
      assert_changes -> { internship_offer.reload.published_at } do
        page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
        wait_form_submitted
        assert_nil internship_offer.reload.published_at, 'fail to unpublish'

        page.find("a[data-test-id=\"toggle-publish-#{internship_offer.id}\"]").click
        wait_form_submitted
        assert_in_delta Time.now.utc.to_i,
                        internship_offer.reload.published_at.utc.to_i,
                        delta = 10
      end
    end
  end
end
