# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  test 'home' do
    get root_path
    assert_response :success
    assert_template 'pages/home'
    assert_select 'a[href=?]', internship_offers_path
  end

  test '10_commandements_d_une_bonne_offre' do
    get les_10_commandements_d_une_bonne_offre_path
    assert_response :success
    assert_template 'pages/les_10_commandements_d_une_bonne_offre'
  end

  test 'exemple_offre_ideale_ministere' do
    get exemple_offre_ideale_ministere_path
    assert_response :success
    assert_template 'pages/exemple_offre_ideale_ministere'
  end

  test 'exemple_offre_ideale_sport' do
    get exemple_offre_ideale_sport_path
    assert_response :success
    assert_template 'pages/exemple_offre_ideale_sport'
  end

  test 'GET pages#partenaires works' do
    get partenaires_path
    assert_response :success
    assert_template 'pages/partenaires'
  end

  test 'GET pages#mentions_legales works' do
    get mentions_legales_path
    assert_response :success
    assert_template 'pages/mentions_legales'
  end

  test 'GET pages#conditions_d_utilisation works' do
    get conditions_d_utilisation_path
    assert_response :success
    assert_template 'pages/conditions_d_utilisation'
  end

  test 'GET pages#contact works' do
    get contact_path
    assert_response :success
    assert_template 'pages/contact'
  end

  test 'GET pages#accessibilite works' do
    get accessibilite_path
    assert_response :success
    assert_template 'pages/accessibilite'
  end
end
