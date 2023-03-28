# frozen_string_literal: true
require 'application_system_test_case'

class InternshipOfferSearchMobileTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers
  include ::SearchInternshipOfferHelpers

  def submit_form
    find('#test-mobile-submit-search').click
  end

  def edit_search
    find('a[data-test-id="mobile-search-button"]').click
    find('.test-search-container')
  end

  test 'USE_IPHONE_EMULATION, search form is hidden, only shows cta to navigate to extracted form in a simple view' do
    visit internship_offers_path

    assert_selector('.search-container', visible: false)
    # assert_selector('a[data-test-id="mobile-search-button"]', visible: true)
    # find('a[data-test-id="mobile-search-button"]').click
    # find(".modal-fullscreen-lg")
  end

  test 'USE_IPHONE_EMULATION, search by location (city) works' do
    internship_offer_at_paris = create(:internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit search_internship_offers_path
    fill_in_city_or_zipcode(with: 'Pari', expect: 'Paris')
    submit_form

    # assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    # edit_search
    # fill_in_city_or_zipcode(with: '', expect: '')
    # submit_form
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    # assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'USE_IPHONE_EMULATION, search by location (zipcodes) works' do
    internship_offer_at_paris = create(:internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit search_internship_offers_path
    fill_in_city_or_zipcode(with: '75012', expect: 'Paris')

    submit_form
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    # edit_search
    # fill_in_city_or_zipcode(with: '', expect: '')
    # submit_form
    # assert_presence_of(internship_offer: internship_offer_at_paris)
    # assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'USE_IPHONE_EMULATION, search by keyword works' do
    searched_keyword = 'helloworld'
    searched_internship_offer = create(:internship_offer, title: searched_keyword)
    not_searched_internship_offer = create(:internship_offer)
    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
    InternshipOfferKeyword.update_all(searchable: true)

    visit search_internship_offers_path
    fill_in_keyword(keyword: searched_keyword)
    submit_form
    # assert_presence_of(internship_offer: searched_internship_offer)
    assert_absence_of(internship_offer: not_searched_internship_offer)

    # reset search and submit
    # edit_search
    # fill_in_keyword(keyword: '')
    # submit_form
    # assert_presence_of(internship_offer: searched_internship_offer)
    # assert_presence_of(internship_offer: not_searched_internship_offer)
  end

  test 'USE_IPHONE_EMULATION, search by week works' do
    travel_to(Date.new(2020,9,6)) do
      searched_week = Week.selectable_from_now_until_end_of_school_year.first
      not_searched_week = Week.selectable_from_now_until_end_of_school_year.last

      searched_internship_offer = create(:internship_offer,
                                         weeks: [searched_week])
      not_searched_internship_offer = create(:internship_offer,
                                             weeks: [not_searched_week])
      visit search_internship_offers_path

      fill_in_week(week: searched_week, open_popover: false)
      submit_form
      # assert_presence_of(internship_offer: searched_internship_offer)
      # assert_absence_of(internship_offer: not_searched_internship_offer)
      # TODO: ensure weeks navigation and months navigation
    end

  end

  test 'USE_IPHONE_EMULATION, search by all criteria' do
    travel_to(Date.new(2022,1,10)) do
      searched_keyword = 'helloworld'
      searched_week = Week.selectable_from_now_until_end_of_school_year.first
      searched_location = Coordinates.paris
      not_searched_keyword = 'bouhbouh'
      not_searched_week = Week.selectable_from_now_until_end_of_school_year.last
      not_searched_location = Coordinates.bordeaux
      searched_opts = { title: searched_keyword,
                        coordinates: searched_location,
                        weeks: [searched_week]}
      # build findable
      findable_internship_offer = create(:internship_offer, searched_opts)

      # build ignored
      not_found_by_location = create(
        :internship_offer,
        searched_opts.merge(coordinates: Coordinates.bordeaux)
      )
      not_found_by_keyword = create(
        :internship_offer,
        searched_opts.merge(title: not_searched_keyword)
      )
      not_found_by_week = create(
        :internship_offer,
        searched_opts.merge(weeks: [not_searched_week])
      )

      dictionnary_api_call_stub
      SyncInternshipOfferKeywordsJob.perform_now
      InternshipOfferKeyword.update_all(searchable: true)

      visit search_internship_offers_path

      fill_in_city_or_zipcode(with: 'Pari', expect: 'Paris')
      fill_in_keyword(keyword: searched_keyword)
      fill_in_week(week: searched_week, open_popover: false)
      submit_form

      # assert_presence_of(internship_offer: findable_internship_offer)
      assert_absence_of(internship_offer: not_found_by_location)
      assert_absence_of(internship_offer: not_found_by_keyword)
      assert_absence_of(internship_offer: not_found_by_week)
    end
  end
end
