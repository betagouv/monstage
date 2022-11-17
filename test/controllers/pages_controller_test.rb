# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'home' do
    get root_path
    assert_response :success
    assert_template 'pages/home'
    assert_select 'title', "Accueil | Monstage"
  end

  test '10_commandements_d_une_bonne_offre' do
    get les_10_commandements_d_une_bonne_offre_path
    assert_response :success
    assert_template 'pages/les_10_commandements_d_une_bonne_offre'
    assert_select 'title', "Les 10 commandements pour une bonne offre | Monstage"
  end

  test 'exemple_offre_ideale_ministere' do
    get exemple_offre_ideale_ministere_path
    assert_response :success
    assert_template 'pages/exemple_offre_ideale_ministere'
    assert_select 'title', "Exemple d'offre idéale (ministère) | Monstage"
  end

  test 'exemple_offre_ideale_sport' do
    get exemple_offre_ideale_sport_path
    assert_response :success
    assert_template 'pages/exemple_offre_ideale_sport'
    assert_select 'title', "Exemple d'offre idéale (sport) | Monstage"
  end

  test 'GET pages#partenaires works' do
    get partenaires_path
    assert_response :success
    assert_template 'pages/partenaires'
    assert_select 'title', "Pages partenaires | Monstage"
  end

  test 'GET pages#mentions_legales works' do
    get mentions_legales_path
    assert_response :success
    assert_template 'pages/mentions_legales'
    assert_select 'title', "Mentions légales | Monstage"
  end

  test 'GET pages#conditions_d_utilisation works' do
    get conditions_d_utilisation_path
    assert_response :success
    assert_template 'pages/conditions_d_utilisation'
    assert_select 'title', "Conditions d'utilisation | Monstage"
  end

  test 'GET pages#contact works' do
    get contact_path
    assert_response :success
    assert_template 'pages/contact'
    assert_select 'title', "Contact | Monstage"
  end

  test 'GET pages#accessibilite works' do
    get accessibilite_path
    assert_response :success
    assert_template 'pages/accessibilite'
    assert_select 'title', "Accessibilité | Monstage"
  end

  test 'GET pages#statistiques works' do
    get statistiques_path
    assert_response :success
    assert_template 'pages/statistiques'
  end

  test '#register_to_webinar fails when not referent' do
    student = create(:student)
    sign_in student
    get register_to_webinar_path
    assert_redirected_to root_path
  end

  test '#register_to_webinar succeds when never registered' do
    travel_to Time.zone.local(2021, 1, 1, 12, 0, 0) do
      webinar_url = 'https://app.livestorm.co/incubateur-des-territoires/permanence-monstagedetroisiemefr?type=detailed'
      ministry_statistician = create(:ministry_statistician)
      sign_in ministry_statistician
      get register_to_webinar_path
      assert_redirected_to webinar_url
      assert_equal ministry_statistician.subscribed_to_webinar_at.to_date, Time.zone.today
    end
  end

  test '#register_to_webinar succeds when registered more than a week ago' do
    travel_to Time.zone.local(2021, 1, 1, 12, 0, 0) do
      webinar_url = 'https://app.livestorm.co/incubateur-des-territoires/permanence-monstagedetroisiemefr?type=detailed'
      ministry_statistician = create(:ministry_statistician, subscribed_to_webinar_at: Time.zone.now - 8.days)
      sign_in ministry_statistician
      get register_to_webinar_path
      assert_redirected_to webinar_url
      assert_equal ministry_statistician.subscribed_to_webinar_at.to_date, Time.zone.today
    end
  end

  test '#register_to_webinar wont succeed when never registered for less than a week' do
    travel_to Time.zone.local(2021, 1, 1, 12, 0, 0) do
      webinar_url = 'https://app.livestorm.co/incubateur-des-territoires/permanence-monstagedetroisiemefr?type=detailed'
      ministry_statistician = create(:ministry_statistician, subscribed_to_webinar_at: Time.zone.now - 2.days)
      sign_in ministry_statistician
      get register_to_webinar_path
      follow_redirect!
      assert_select('#alert-text', text: 'Vous êtes déjà inscrit au prochain webinar Monstage')
    end
  end
end
