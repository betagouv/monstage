# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOfferSearchDesktopTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::SearchInternshipOfferHelpers
  include ::ApiTestHelpers

  def submit_form
    find('#test-desktop-submit-search').click
  end

  test 'search form is visible' do
    visit internship_offers_path

    assert_selector('.search-container', visible: true)
    assert_selector('a[data-test-id="mobile-search-button"]', visible: false)
  end

  test 'search by location (city) works' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                          city: 'Bordeaux',
                                          coordinates: Coordinates.bordeaux)

    visit internship_offers_path
    fill_in_city_or_zipcode(with: 'Pari ', expect: 'Paris')
    submit_form
    # all('.fr-card').first.click

    assert_card_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    fill_in_city_or_zipcode(with: '', expect: '')
    submit_form
    assert_card_presence_of(internship_offer: internship_offer_at_paris)
    assert_card_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'search by location (zipcodes) works' do
    travel_to (Date.new(2023, 9, 6)) do
      internship_offer_at_paris = create(:weekly_internship_offer,
                                        coordinates: Coordinates.paris)
      internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                            coordinates: Coordinates.bordeaux)

      visit internship_offers_path
      fill_in_city_or_zipcode(with: '75012', expect: 'Paris')

      submit_form
      assert_card_presence_of(internship_offer: internship_offer_at_paris)
      assert_absence_of(internship_offer: internship_offer_at_bordeaux)

      # reset search and submit
      fill_in_city_or_zipcode(with: '', expect: '')
      submit_form
      # assert_presence_of(internship_offer: internship_offer_at_paris)
      # assert_presence_of(internship_offer: internship_offer_at_bordeaux)
    end
  end



  test 'search by keyword works' do
    searched_keyword = 'helloworld'
    searched_internship_offer = create(:weekly_internship_offer, title: searched_keyword)
    not_searched_internship_offer = create(:weekly_internship_offer)
    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now
    InternshipOfferKeyword.update_all(searchable: true)

    visit internship_offers_path
    fill_in_keyword(keyword: searched_keyword)
    submit_form
    assert_card_presence_of(internship_offer: searched_internship_offer)
    assert_absence_of(internship_offer: not_searched_internship_offer)

    # reset search and submit
    fill_in_keyword(keyword: '')
    submit_form
    assert_card_presence_of(internship_offer: searched_internship_offer)
    assert_card_presence_of(internship_offer: not_searched_internship_offer)
  end

  test 'search by week works' do
    travel_to(Date.new(2022, 9, 6)) do
      searched_week = Week.selectable_from_now_until_end_of_school_year.first
      not_searched_week = Week.selectable_from_now_until_end_of_school_year.last

      searched_internship_offer = create(:weekly_internship_offer,
                                         weeks: [searched_week])
      not_searched_internship_offer = create(:weekly_internship_offer,
                                             weeks: [not_searched_week])
      visit internship_offers_path
      fill_in_week(week: searched_week, open_popover: true)
      submit_form
      assert_card_presence_of(internship_offer: searched_internship_offer)
      assert_absence_of(internship_offer: not_searched_internship_offer)
      # TODO: ensure weeks navigation and months navigation
    end
  end

  test 'search by all criteria' do
    travel_to(Date.new(2022, 1, 6)) do
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

      dictionnary_api_call_stub
      SyncInternshipOfferKeywordsJob.perform_now
      InternshipOfferKeyword.update_all(searchable: true)

      visit internship_offers_path

      fill_in_city_or_zipcode(with: 'Pari', expect: 'Paris')
      fill_in_keyword(keyword: searched_keyword)
      fill_in_week(week: searched_week, open_popover: true)
      submit_form

      assert_card_presence_of(internship_offer: findable_internship_offer)
      assert_absence_of(internship_offer: not_found_by_location)
      assert_absence_of(internship_offer: not_found_by_keyword)
      assert_absence_of(internship_offer: not_found_by_week)
    end
  end
end
