# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferSearchMobileTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  # TODO, rewrite tests for mobile search (with navigation to search form)
  test 'search form is hidden, only shows cta to navigate to extracted form in a simple view' do
    assert false
  end

  test 'search by location (city) works' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit internship_offers_path
    # check everything is here by default
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)

    assert false
    # TODO: rework, application_system_test_casert searching
    # fill_in('Autour de', with: 'Pari')
    # find('#test-input-location-container #downshift-1-item-0').click
    # assert_equal 'Paris',
    #              find('#test-input-location-container #input-search-by-city-or-zipcode').value,
    #              'click on list view does not fill location input'

    # # submit search and check result had been filtered
    # find('button#test-submit-search').click
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    # assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # # reset search and submit
    # fill_in('Autour de', with: '')
    # # submit search and check result had been filtered
    # find('button#test-submit-search').click
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    # assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'search by location (zipcodes) works' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit internship_offers_path
    # check everything is here by default
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)

    assert false
    # TODO: rework, application_system_test_casert searching
    # fill_in('Autour de', with: '75012')
    # find('#test-input-location-container #downshift-1-item-0').click
    # assert_equal 'Paris',
    #               find('#test-input-location-container #input-search-by-city-or-zipcode').value,
    #               'click on list view does not fill location input'

    # # submit search and check result had been filtered
    # find('button#test-submit-search').click
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    # assert_absence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'search by school_track works' do
    school                              = create(:school)
    school_manager                      = create(:school_manager, school: school)
    teacher                             = create(:main_teacher, school: school)
    weekly_internship_offer = create(:weekly_internship_offer)
    bac_pro_internship_offer            = create(:bac_pro_internship_offer)
    sign_in(teacher)

    visit internship_offers_path

    # all offers presents
    assert_presence_of(internship_offer: weekly_internship_offer)
    assert_presence_of(internship_offer: bac_pro_internship_offer)

    assert false
    # TODO: rework, filter
    # find('label[for="search-by-troisieme-generale"]').click
    # assert_presence_of(internship_offer: weekly_internship_offer)
    # assert_absence_of(internship_offer: bac_pro_internship_offer)

    # # filtered by middle-school
    # find('label[for="search-by-bac-pro"]').click
    # assert_absence_of(internship_offer: weekly_internship_offer)
    # assert_presence_of(internship_offer: bac_pro_internship_offer)

    # # uncheck selection make both search active == "Toutes"
    # find('label[for="search-by-bac-pro"]').click
    # assert_presence_of(internship_offer: weekly_internship_offer)
    # assert_presence_of(internship_offer: bac_pro_internship_offer)
  end

  test 'search by keyword works' do
    searched_keyword = 'helloworld'
    searched_internship_offer = create(:weekly_internship_offer, title: searched_keyword)
    not_searched_internship_offer = create(:weekly_internship_offer)

    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
    InternshipOfferKeyword.update_all(searchable: true)

    visit internship_offers_path
    # check everything is here by default
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_presence_of(internship_offer: not_searched_internship_offer)

    assert false
    # TODO rework, start searching
    # fill_in('Rechercher par Profession', with: searched_keyword[0..5])
    # find('#test-input-keyword-container .listview-item').click
    # assert_equal searched_keyword,
    #              find('#test-input-keyword-container #input-search-by-keyword').value,
    #              'click on list view does not fill keyword input'

    # # submit search and check result had been filtered
    # find('button#test-submit-search').click
    # assert_presence_of(internship_offer: searched_internship_offer)
    # assert_absence_of(internship_offer: not_searched_internship_offer)

    # # reset search and submit
    # fill_in('Rechercher par Profession', with: '')

    # # submit search and check result had been filtered
    # find('button#test-submit-search').click
    # assert_presence_of(internship_offer: searched_internship_offer)
    # assert_presence_of(internship_offer: not_searched_internship_offer)
  end

  test 'search by all criteria' do
    assert false
  end
end
