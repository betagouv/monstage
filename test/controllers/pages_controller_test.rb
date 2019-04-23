require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  test "home" do
    get root_path
    assert_response :success
    assert_template 'pages/home'
  end

  test "10_commandements_d_une_bonne_offre" do
    get les_10_commandements_d_une_bonne_offre_path
    assert_response :success
    assert_template 'pages/les_10_commandements_d_une_bonne_offre'
  end

  test "exemple_offre_ideale_ministere" do
    get exemple_offre_ideale_ministere_path
    assert_response :success
    assert_template 'pages/exemple_offre_ideale_ministere'
  end

  test "exemple_offre_ideale_sport" do
    get exemple_offre_ideale_sport_path
    assert_response :success
    assert_template 'pages/exemple_offre_ideale_sport'
  end

end
