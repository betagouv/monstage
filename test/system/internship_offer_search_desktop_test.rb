# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferSearchDesktopTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  # TODO, rewrite tests for desktop search (from same view)
  test 'search form is visible' do
    visit internship_offers_path

    assert_selector('.search-container', visible: true)
    assert_selector('a[data_test_id="mobile-search-button"]', visible: false)
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

    find('#input-search-by-city-or-zipcode').fill_in(with: 'Pari')
    find('#test-input-location-container #downshift-1-item-0').click
    assert_equal 'Paris',
                 find('#test-input-location-container #input-search-by-city-or-zipcode').value,
                 'click on list view does not fill location input'

    # submit search and check result had been filtered
    find('input#test-submit-search').click
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # # reset search and submit
    find('#input-search-by-city-or-zipcode').fill_in(with: '')
    # submit search and check result had been filtered
    find('input#test-submit-search').click
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)
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

    find('#input-search-by-city-or-zipcode').fill_in(with: '75012')
    find('#test-input-location-container #downshift-1-item-0').click
    assert_equal 'Paris',
                  find('#test-input-location-container #input-search-by-city-or-zipcode').value,
                  'click on list view does not fill location input'

    # # submit search and check result had been filtered
    find('input#test-submit-search').click
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)
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

    select('3ème')
    find('input#test-submit-search').click
    assert_presence_of(internship_offer: weekly_internship_offer)
    assert_absence_of(internship_offer: bac_pro_internship_offer)
    assert_selector("#input-search-by-week[readonly]", count: 0)
    assert_selector("#input-search-by-week", count: 1)

    # # filtered by middle-school
    select('Bac pro')
    find('input#test-submit-search').click
    assert_absence_of(internship_offer: weekly_internship_offer)
    assert_presence_of(internship_offer: bac_pro_internship_offer)
    assert_selector("#input-search-by-week[readonly]", count: 1)

    select("Filière")
    find('input#test-submit-search').click
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

    visit internship_offers_path
    # check everything is here by default
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_presence_of(internship_offer: not_searched_internship_offer)

    find("#input-search-by-keyword").fill_in(with: searched_keyword[0..5])
    find('#test-input-keyword-container .listview-item').click
    assert_equal searched_keyword,
                 find('#test-input-keyword-container #input-search-by-keyword').value,
                 'click on list view does not fill keyword input'

    # submit search and check result had been filtered
    find('input#test-submit-search').click
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_absence_of(internship_offer: not_searched_internship_offer)

    # # reset search and submit
    find("#input-search-by-keyword").fill_in(with: '')

    # # submit search and check result had been filtered
    find('input#test-submit-search').click
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
      visit internship_offers_path

      assert_presence_of(internship_offer: searched_internship_offer)
      assert_presence_of(internship_offer: not_searched_internship_offer)

      select('3ème')
      find("#input-search-by-week").click
      find("#checkbox_#{searched_week.id}").click
      find('input#test-submit-search').click
      assert_presence_of(internship_offer: searched_internship_offer)
      assert_absence_of(internship_offer: not_searched_internship_offer)
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

    visit internship_offers_path

    find('#input-search-by-city-or-zipcode').fill_in(with: 'Pari')
    find('#test-input-location-container #downshift-1-item-0').click
    select('3ème')
    find("#input-search-by-keyword").fill_in(with: searched_keyword[0..5])
    find('#test-input-keyword-container .listview-item').click
    find("#input-search-by-week").click
    find("#checkbox_#{searched_week.id}").click
    find('input#test-submit-search').click

    assert_presence_of(internship_offer: findable_internship_offer)
    assert_absence_of(internship_offer: not_found_by_location)
    assert_absence_of(internship_offer: not_found_by_keyword)
    assert_absence_of(internship_offer: not_found_by_week)
    assert_absence_of(internship_offer: not_found_by_school_track)
  end
end
