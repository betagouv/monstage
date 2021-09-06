# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferSearchMobileTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers
  include ::SearchInternshipOfferHelpers
  driven_by :selenium, using: ENV.fetch('BROWSER') { 'headless_chrome' }.to_sym,
                       screen_size: [375, 812]


  def submit_form
    find('input#test-mobile-submit-search').click
  end

  def edit_search
    find('a[data_test_id="mobile-search-button"]').click
    find('.search-container')
  end

  test 'search form is hidden, only shows cta to navigate to extracted form in a simple view' do
    visit internship_offers_path

    assert_selector('.search-container', visible: false)
    assert_selector('a[data_test_id="mobile-search-button"]', visible: true)
    find('a[data_test_id="mobile-search-button"]"').click
    find(".modal-fullscreen-lg")
  end

  test 'search by location (city) works' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit search_internship_offers_path
    fill_in_city_or_zipcode(with: 'Pari', expect: 'Paris')
    submit_form

    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    edit_search
    fill_in_city_or_zipcode(with: '', expect: '')
    submit_form
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'search by location (zipcodes) works' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit search_internship_offers_path
    fill_in_city_or_zipcode(with: '75012', expect: 'Paris')

    submit_form
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    edit_search
    fill_in_city_or_zipcode(with: '', expect: '')
    submit_form
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'search by school_track works' do
    weekly_internship_offer = create(:weekly_internship_offer)
    bac_pro_internship_offer = create(:bac_pro_internship_offer)
    visit search_internship_offers_path

    select('3ème')
    submit_form
    assert_presence_of(internship_offer: weekly_internship_offer)
    assert_absence_of(internship_offer: bac_pro_internship_offer)
    # ensure selection of school track disable week placeholder input
    assert_selector("#input-search-by-week[readonly]", count: 0)
    assert_selector("#input-search-by-week", count: 1)
    # TODO: ensure selection of school track disable week checkboxes

    # filtered by another
    edit_search
    select('Bac pro')
    submit_form
    assert_absence_of(internship_offer: weekly_internship_offer)
    assert_presence_of(internship_offer: bac_pro_internship_offer)
    assert_selector("#input-search-by-week[readonly]", count: 1)

    # reset search and submit
    edit_search
    select("Filière")
    submit_form
    assert_presence_of(internship_offer: weekly_internship_offer)
    assert_presence_of(internship_offer: bac_pro_internship_offer)
  end

  test 'search by keyword works' do
    searched_keyword = 'helloworld'
    searched_internship_offer = create(:weekly_internship_offer, title: searched_keyword)
    not_searched_internship_offer = create(:weekly_internship_offer)
    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
    InternshipOfferKeyword.update_all(searchable: true)

    visit search_internship_offers_path
    fill_in_keyword(keyword: searched_keyword)
    submit_form
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_absence_of(internship_offer: not_searched_internship_offer)

    # reset search and submit
    edit_search
    fill_in_keyword(keyword: '')
    submit_form
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_presence_of(internship_offer: not_searched_internship_offer)
  end

  test 'search by week works' do
    travel_to(Date.new(2020,9,6)) do
      searched_week = Week.selectable_from_now_until_end_of_school_year.first
      not_searched_week = Week.selectable_from_now_until_end_of_school_year.last

      searched_internship_offer = create(:weekly_internship_offer,
                                         weeks: [searched_week])
      not_searched_internship_offer = create(:weekly_internship_offer,
                                             weeks: [not_searched_week])
      visit search_internship_offers_path

      select('3ème')
      fill_in_week(week: searched_week)
      submit_form
      assert_presence_of(internship_offer: searched_internship_offer)
      assert_absence_of(internship_offer: not_searched_internship_offer)
      # TODO: ensure weeks navigation and months navigation
    end

  end

  test 'search by all criteria' do
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
    findable_internship_offer = create(:weekly_internship_offer, searched_opts)

    # build ignored
    not_found_by_location = create(
      :weekly_internship_offer,
      searched_opts.merge(coordinates: Coordinates.bordeaux)
    )
    not_found_by_keyword = create(
      :weekly_internship_offer,
      searched_opts.merge(title: not_searched_keyword)
    )
    not_found_by_week = create(
      :weekly_internship_offer,
      searched_opts.merge(weeks: [not_searched_week])
    )
    not_found_by_school_track = create(
      :bac_pro_internship_offer,
      searched_opts.reject { |k,v| k == :weeks }
    )

    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
    InternshipOfferKeyword.update_all(searchable: true)

    visit search_internship_offers_path

    fill_in_city_or_zipcode(with: 'Pari', expect: 'Paris')
    fill_in_keyword(keyword: searched_keyword)
    select('3ème')
    fill_in_week(week: searched_week)
    submit_form

    assert_presence_of(internship_offer: findable_internship_offer)
    assert_absence_of(internship_offer: not_found_by_location)
    assert_absence_of(internship_offer: not_found_by_keyword)
    assert_absence_of(internship_offer: not_found_by_week)
    assert_absence_of(internship_offer: not_found_by_school_track)
  end
end
