# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  include ThirdPartyTestHelpers

  test 'home' do
    # write a mock : File.open(Rails.root.join('test', 'fixtures', 'files', 'prismic-homepage-response.dump'), 'wb') { |fd| fd.write Marshal.dump(rs) }
    # read a mock : Marshal.load(File.read(Rails.root.join('test', 'fixtures', 'files', 'prismic-homepage-response.dump')))
    # mock with mock : PrismicFinder.stub(:homepage, mock_prismic)
    prismic_root_path_stubbing do
      get root_path
      assert_response :success
      assert_template 'pages/home'
      assert_select 'title', "Accueil | Monstage"
    end
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
end
