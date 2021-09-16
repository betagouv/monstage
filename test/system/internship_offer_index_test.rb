# frozen_string_literal: true

require 'application_system_test_case'

class StudentFilterOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[data-test-id='#{internship_offer.id}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[data-test-id='#{internship_offer.id}']"
  end

  test 'navigation & interaction works' do
    school = create(:school)
    student = create(:student, school: school)
    internship_offer = create(:weekly_internship_offer)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit internship_offers_path

        assert_presence_of(internship_offer: internship_offer)
      end
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
    # check everything is here by default
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_presence_of(internship_offer: not_searched_internship_offer)

    # start searching
    fill_in('Rechercher par Profession', with: searched_keyword[0..5])
    find('#test-input-keyword-container .listview-item').click
    assert_equal searched_keyword,
                 find('#test-input-keyword-container #input-search-by-keyword').value,
                 'click on list view does not fill keyword input'

    # submit search and check result had been filtered
    find('button#test-submit-search').click
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_absence_of(internship_offer: not_searched_internship_offer)

    # reset search and submit
    fill_in('Rechercher par Profession', with: '')

    # submit search and check result had been filtered
    find('button#test-submit-search').click
    assert_presence_of(internship_offer: searched_internship_offer)
    assert_presence_of(internship_offer: not_searched_internship_offer)
  end

  test 'search by location works' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit internship_offers_path
    # check everything is here by default
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)

    # application_system_test_casert searching
    fill_in('Autour de', with: 'Pari')
    find('#test-input-location-container #downshift-1-item-0').click
    assert_equal 'Paris',
                 find('#test-input-location-container #input-search-by-city-or-zipcode').value,
                 'click on list view does not fill location input'

    # submit search and check result had been filtered
    find('button#test-submit-search').click
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)

    # reset search and submit
    fill_in('Autour de', with: '')
    # submit search and check result had been filtered
    find('button#test-submit-search').click
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)
  end

  test 'visitor is lured into thinking he can submit an application' do
    create(:weekly_internship_offer)
    visit internship_offers_path
    page.find_link('Postuler')
  end

  test 'as teacher, search filters are complete and do filter by school_track' do
    school                           = create(:school)
    school_manager                   = create(:school_manager, school: school)
    teacher                          = create(:main_teacher, school: school)
    weekly_internship_offer          = create(:weekly_internship_offer)
    troisieme_segpa_internship_offer = create(:troisieme_segpa_internship_offer)
    sign_in(teacher)

    visit internship_offers_path

    # all offers presents
    assert_presence_of(internship_offer: weekly_internship_offer)
    assert_presence_of(internship_offer: troisieme_segpa_internship_offer)

    # filter
    find('label[for="search-by-troisieme-generale"]').click
    assert_presence_of(internship_offer: weekly_internship_offer)
    assert_absence_of(internship_offer: troisieme_segpa_internship_offer)

    # filtered by middle-school
    find('label[for="search-by-troisieme-segpa"]').click
    assert_absence_of(internship_offer: weekly_internship_offer)
    assert_presence_of(internship_offer: troisieme_segpa_internship_offer)

    # uncheck selection make both search active == "Toutes"
    find('label[for="search-by-troisieme-segpa"]').click
    assert_presence_of(internship_offer: weekly_internship_offer)
    assert_presence_of(internship_offer: troisieme_segpa_internship_offer)
  end

  test 'as student, search filters are not available and ' \
       'offers are linked to student\'s class_room\'s school track' do
    school = create(:school)
    class_room = ClassRoom.create(
      name: '3e B – troisieme_prepa_metiers',
      school_track: :troisieme_prepa_metiers,
      school: school
    )
    student = create(:student, school: school, class_room: class_room)
    troisieme_prepa_metiers_internship_offer = create(:troisieme_prepa_metiers_internship_offer)
    weekly_internship_offer = create(:weekly_internship_offer)
    troisieme_segpa_internship_offer = create(:troisieme_segpa_internship_offer)
    sign_in(student)
    visit internship_offers_path

    assert page.has_no_content? "Filtrer par"
    find('span.troisieme_prepa_metiers', text: '3e prépa métiers')
    assert page.has_no_selector?('span.troisieme_generale')
    assert page.has_no_content? "3e SEGPA"

    assert page.has_content? "3e prépa métier", count: 1
    assert_presence_of(internship_offer: troisieme_prepa_metiers_internship_offer)

    assert_absence_of(internship_offer: weekly_internship_offer)
    assert_absence_of(internship_offer: troisieme_segpa_internship_offer)
  end

  test 'one can search internship offers with zipcodes' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                          coordinates: Coordinates.bordeaux)

    visit internship_offers_path
    # check everything is here by default
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_presence_of(internship_offer: internship_offer_at_bordeaux)

    # application_system_test_casert searching
    fill_in('Autour de', with: '75012')
    find('#test-input-location-container #downshift-1-item-0').click
    assert_equal 'Paris',
                  find('#test-input-location-container #input-search-by-city-or-zipcode').value,
                  'click on list view does not fill location input'

    # submit search and check result had been filtered
    find('button#test-submit-search').click
    assert_presence_of(internship_offer: internship_offer_at_paris)
    assert_absence_of(internship_offer: internship_offer_at_bordeaux)
    
    # visit internship_offers_path
    # fill_in('Autour de', with: '98554')
    # assert_equal '98554',
    #               find('#test-input-location-container #input-search-by-city-or-zipcode').value,
    #               'click on list view does not fill location input'

    # click_button('Rechercher').click
    # # sleep 3

    # # set_
    # new_search_content = find('#test-input-location-container #input-search-by-city-or-zipcode').value
    # assert_equal '98554 : code postal invalide',
    #              new_search_content,
    #              'search is to detect wrong codes postaux'


  end
end
