# frozen_string_literal: true

require 'application_system_test_case'
# TODO: webmock
class InternshipOffersCreateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'can create internship offer' do
    schools = [create(:school), create(:school)]
    sectors = [create(:sector), create(:sector)]
    employer = create(:employer)
    sign_in(employer)
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit '/dashboard'
        click_on 'Déposer une offre'
        fill_in 'internship_offer_title', with: 'Stage de dev @betagouv.fr ac Brice & Martin'
        fill_in 'internship_offer_description', with: "Le dev plus qu'une activité, un lifestyle.\n Venez découvrir comment creer les outils qui feront le monde de demain"
        select sectors.first.name, from: 'internship_offer_sector_id'
        select Week.find_by(number: 9, year: 2019).select_text_method, from: 'internship_offer_week_ids'
        select Week.find_by(number: 10, year: 2019).select_text_method, from: 'internship_offer_week_ids'
        fill_in 'Prénom et nom', with: 'Brice Durand'
        fill_in 'Adresse électronique', with: 'le@brice.durand'
        fill_in 'Téléphone', with: '0639693969'
        fill_in "Nom de l'entreprise ou de l'administration", with: 'BetaGouv'
        fill_in 'Activités', with: "On fait des startup d'état qui déchirent"
        fill_in 'Site web', with: 'https://beta.gouv.fr/'

        fill_in 'Adresse du lieu où se déroule le stage', with: 'Paris, 13eme'
        page.all('.algolia-places div[role="option"]')[0].click
        click_on 'Soumettre'
      end
    end
    assert_equal employer, InternshipOffer.first.employer
  end
end
