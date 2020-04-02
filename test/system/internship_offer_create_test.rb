# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOffersCreateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'can create internship offer' do
    schools = [create(:school), create(:school)]
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    group = create(:group, name: 'hello', is_public: true)
    sign_in(employer)
    available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
    assert_difference 'InternshipOffers::Web.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit employer.custom_dashboard_path
        find('#test-create-offer').click
        fill_in 'internship_offer_title', with: 'Stage de dev @betagouv.fr ac Brice & Martin'
        find('#internship_offer_description_rich_text', visible: false).set("Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment creer les outils qui feront le monde de demain")
        select sectors.first.name, from: 'internship_offer_sector_id'
        find(:css, "label[for=internship_offer_week_ids_#{available_weeks.first.id}]").click
        find(:css, "label[for=internship_offer_week_ids_#{available_weeks.last.id}]").click
        fill_in 'Nom du tuteu/trice', with: 'Brice Durand'
        fill_in 'Adresse électronique (ex : mon@exemple.fr)', with: 'le@brice.durand'
        fill_in 'Téléphone (ex : 06 12 34 56 78)', with: '0639693969'
        fill_in "Nom de la structure ou du service proposant l'offre", with: 'BetaGouv'
        find('#internship_offer_employer_description_rich_text', visible: false).set("On fait des startup d'état qui déchirent")
        fill_in 'Site web (facultatif)', with: 'https://beta.gouv.fr/'
        find('label', text: 'public').click
        select group.name, from: 'internship_offer_group_id'
        fill_in "Ville du lieu où se déroule le stage (la plus proche si vous ne trouvez pas la votre)", with: 'Paris, 13eme'
        page.all('.algolia-places div[role="option"]')[0].click
        fill_in "Rue ou compléments d'adresse", with: 'La rue qui existe pas dans algolia place / OSM'
        click_on "Enregistrer et publier l'offre"
        find('.alert-sticky')
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
  end
end
