# frozen_string_literal: true

require 'test_helper'

class IndexTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 1
  end

  def assert_absence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 0
  end

  def assert_json_presence_of(json_response, internship_offer)
    assert json_response['internshipOffers'].any? { |o| o['id'] == internship_offer.id }
  end

  def assert_json_absence_of(json_response, internship_offer)
    assert json_response['internshipOffers'].none? { |o| o['id'] == internship_offer.id }
  end

  def create_offers
    offer_paris_1 = create(
      :weekly_internship_offer,
      title: 'Vendeur'
    )
    offer_paris_2 = create(
      :weekly_internship_offer,
      title: 'Comptable'
    )
    offer_paris_3 = create(
      :weekly_internship_offer,
      title: 'Infirmier'
    )
    offer_bordeaux_1 = create(
      :weekly_internship_offer,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )
  end

  test 'GET #index as "Users::Visitor" works and has a page title' do
    get internship_offers_path
    assert_response :success
    assert_select 'title', 'Recherche de stages | Monstage'
  end

  test 'GET #index with coordinates as "Users::Visitor" works' do
    get internship_offers_path(latitude: 44.8378, longitude: -0.579512)
    assert_response :success
  end

  test 'GET #index with wrong keyword as Visitor returns no results' do
    create_offers
    get internship_offers_path(keyword: 'avocat', format: :json)
    assert_response :success
    assert_empty json_response['internshipOffers']
    assert_equal 0, UsersSearchHistory.count
  end

  test 'GET #index with wrong keyword as Student returns no results' do
    create_offers
    sign_in(create(:student))
    get internship_offers_path(keyword: 'avocat', format: :json)
    assert_response :success
    assert_empty json_response['internshipOffers']
    assert_equal 1, UsersSearchHistory.count
    assert_equal 'avocat', UsersSearchHistory.last.keywords
    assert_equal 0, UsersSearchHistory.last.results_count
  end

  test 'GET #index with wrong coordinates as Visitor returns no results' do
    create_offers
    get internship_offers_path(latitude: 4.8378, longitude: -0.579512, format: :json)
    assert_response :success
    assert_empty json_response['internshipOffers']
  end

  test 'GET #index ignore default radius in suggestions' do
    offer_paris_1 = create(
      :weekly_internship_offer,
      title: 'Vendeur'
    )

    get internship_offers_path(
      keyword: 'avocat',
      radius: Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER,
      format: :json)

    assert_response :success
    assert_empty json_response['internshipOffers']
    assert_absence_of(internship_offer: offer_paris_1)
  end

  test 'GET #index with wrong keyword and Paris location as Visitor returns no results' do
    offer_paris_1 = create(
      :weekly_internship_offer,
      title: 'Vendeur'
    )
    offer_paris_2 = create(
      :weekly_internship_offer,
      title: 'Comptable'
    )
    offer_paris_3 = create(
      :weekly_internship_offer,
      title: 'Infirmier'
    )
    # not displayed
    offer_bordeaux_1 = create(
      :weekly_internship_offer,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )
    # not displayed
    offer_bordeaux_2 = create(
      :weekly_internship_offer,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )

    get internship_offers_path(
      keyword: 'avocat',
      latitude: Coordinates.paris[:latitude],
      longitude: Coordinates.paris[:longitude],
      radius: 60_000,
      format: :json
    )

    assert_response :success
    assert json_response['isSuggestion']
  end

  test 'GET #index with wrong keyword and wrong weeks as Visitor returns no results with weeks suggestions' do
    offer_paris_1 = create(
      :weekly_internship_offer,
      title: 'Vendeur'
    )
    offer_paris_2 = create(
      :weekly_internship_offer,
      title: 'Comptable'
    )
    # not displayed
    offer_paris_3 = create(
      :weekly_internship_offer,
      title: 'Infirmier',
      week_ids: [1, 2, 3]
    )
    offer_bordeaux_1 = create(
      :weekly_internship_offer,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )
    offer_bordeaux_2 = create(
      :weekly_internship_offer,
      title: 'Infirmier',
      city: 'Bordeaux',
      coordinates: Coordinates.bordeaux
    )

    get internship_offers_path(
      keyword: 'avocat',
      week_ids: offer_paris_1.week_ids,
      format: :json
    )

    assert_response :success
    assert json_response['isSuggestion']
  end

  test 'GET #index canonical links works' do
    get internship_offers_path(latitude: 44.8378, longitude: -0.579512)
    assert_match(
      %r{<link href="http://www.example.com/offres-de-stage" rel="canonical" />}, response.body
    )
    get internship_offers_path(latitude: 44.8378, longitude: -0.579512, page: 2)
    assert_match(
      %r{<link href="http://www.example.com/offres-de-stage\?page=2" rel="canonical" />}, response.body
    )
  end

  test 'GET #index as student ignores internship_offers with existing application' do
    internship_offer_without_application = create(
      :weekly_internship_offer,
      title: 'offer without_application'
    )

    assert_equal 1, InternshipOffers::WeeklyFramed.count

    weeks = internship_offer_without_application.weeks
    school = create(:school, weeks: weeks)
    class_room = create(:class_room,  school: school)
    student = create(:student, school: school, class_room: class_room)
    internship_offer_with_application = create(
      :weekly_internship_offer,
      max_candidates: 2,
      max_students_per_group: 2,
      title: 'offer with_application',
      weeks: weeks)

    internship_application = create(
      :internship_application,
      internship_offer: internship_offer_with_application,
      aasm_state: 'approved',
      student: student,
      week: weeks.first)

    assert_equal 2, InternshipOffers::WeeklyFramed.count
    assert_equal 1, InternshipApplication.count
    assert_equal 1, InternshipApplication.approved.count
    assert_equal 1, internship_offer_with_application.reload.remaining_seats_count

    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        assert_equal 2, InternshipOffers::WeeklyFramed.uncompleted_with_max_candidates.count
        get internship_offers_path, params: { format: :json }
        assert_response :success
        assert_equal 1, json_response['internshipOffers'].count
        assert_json_presence_of(json_response, internship_offer_without_application)
      end
    end
  end

  test 'GET #index as statistician works' do
    statistician = create(:statistician)
    sign_in(statistician)
    get internship_offers_path
    assert_response :success
  end

  test 'GET #index as student. ignores internship offers not published' do
    api_internship_offer         = create(:api_internship_offer)
    internship_offer_published   = create(:weekly_internship_offer)
    internship_offer_unpublished = create(:weekly_internship_offer,:unpublished)
    student = create(:student)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        assert_equal 2, json_response['internshipOffers'].count
        assert_json_absence_of(json_response, internship_offer_unpublished)
        assert_json_presence_of(json_response, api_internship_offer)
        assert_json_presence_of(json_response, internship_offer_published)
      end
    end
  end

  test 'GET #index as visitor does not show discarded offers' do
    discarded_internship_offer = create(:weekly_internship_offer,
                                        discarded_at: 2.days.ago)
    not_discarded_internship_offer = create(:weekly_internship_offer,
                                            discarded_at: nil)
    get internship_offers_path, params: { format: :json }
    assert_json_presence_of(json_response, not_discarded_internship_offer)
    assert_json_absence_of(json_response, discarded_internship_offer)
  end

  test 'GET #index as visitor does not show unpublished offers' do
    published_internship_offer = create(:weekly_internship_offer,
                                        aasm_state: 'published',
                                        published_at: 2.days.ago)
    not_published_internship_offer = create(:weekly_internship_offer, :unpublished)
    get internship_offers_path, params: { format: :json }
    assert_json_presence_of(json_response, published_internship_offer)
    assert_json_absence_of(json_response, not_published_internship_offer)
  end

  test 'GET #index as visitor does not show fulfilled offers' do
    travel_to(Date.new(2022,9,1)) do
      internship_application = create(:weekly_internship_application, :submitted)
      internship_offer = internship_application.internship_offer
      get internship_offers_path, params: { format: :json }
      assert_json_presence_of(json_response, internship_offer)
      internship_application.update!(aasm_state: 'approved')
      get internship_offers_path, params: { format: :json }
      assert_json_absence_of(json_response, internship_offer)
    end
  end

  test 'GET #index as visitor or student default shows both middle school and high school offers' do
    internship_offer_weekly = create(:weekly_internship_offer)
    # Visitor
    get internship_offers_path
    # Student
    school = create(:school, weeks: [])
    student = create(:student, school: school)
    sign_in(student)
    get internship_offers_path
  end


  test 'GET #index as student ignores internship_offers having ' \
       'as much internship_application as max_candidates number' do

    max_candidates = 1
    week = Week.first
    school = create(:school)
    student = create(:student, school: school,
                               class_room: create(:class_room,
                                                  school: school))
    internship_offer = create(:weekly_internship_offer,
                              max_candidates: max_candidates,
                              weeks: [week]
                              )
    internship_application = create(:internship_application,
                                    internship_offer: internship_offer,
                                    week: week)


    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        assert_json_absence_of(json_response, internship_offer)
      end
    end
  end

  test 'GET #index as student keeps internship_offers having ' \
       'as less than blocked_applications_count as max_candidates number' do
    max_candidates = 2
    internship_offer = create(:weekly_internship_offer,
                              max_candidates: max_candidates,
                              max_students_per_group: max_candidates,
                              internship_offer_weeks: [
                                build(:internship_offer_week, blocked_applications_count: max_candidates - 1,
                                                              week: Week.first)
                              ])
    sign_in(create(:student))
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        assert_json_presence_of(json_response, internship_offer)
      end
    end
  end

  test 'GET #index as student finds internship_offers available with one week that is not available' do
    max_candidates = 2
    internship_weeks = [Week.first, Week.last]
    school = create(:school, weeks: internship_weeks)
    blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates - 1,
                                                            week: internship_weeks[0])
    not_blocked_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
    internship_offer = create(:weekly_internship_offer, max_candidates: max_candidates,
                                                        internship_offer_weeks: [blocked_internship_week,
                                                                                 not_blocked_internship_week])
    sign_in(create(:student, school: school))
    
    InternshipOffer.stub :nearby, InternshipOffer.all do
      get internship_offers_path, params: { format: :json }
      assert_json_presence_of(json_response, internship_offer)
    end
  end

  test 'GET #index as student ignores internship_offers not blocked on different week that is not available' do
    max_candidates = 2
    travel_to(Date.new(2019, 3, 1)) do
      internship_weeks = [
        Week.selectable_from_now_until_end_of_school_year.second,
        Week.selectable_from_now_until_end_of_school_year.last
      ]
      internship_offer = create(:weekly_internship_offer,
                                max_candidates: max_candidates, weeks: internship_weeks)
      blocked_internship_week = create(:weekly_internship_application,
                                       internship_offer: internship_offer,
                                       aasm_state: :approved,
                                       week: internship_weeks[0])
      # blocked_internship_week.signed!
      not_blocked_internship_week = create(:weekly_internship_application,
                                           internship_offer: internship_offer,
                                           aasm_state: :submitted,
                                           week: internship_weeks[1])

      sign_in(create(:student))

      get internship_offers_path(week_ids: internship_weeks.map(&:id),
                                 params: { format: :json })
      assert_json_presence_of(json_response, internship_offer)

      get internship_offers_path(week_ids: [internship_weeks[1].id],
                                 params: { format: :json })
      assert_json_presence_of(json_response, internship_offer)
    end
  end

  test 'GET #index as student finds internship_offers blocked on other weeks' do
    max_candidates = 2
    internship_weeks = [Week.first, Week.last]
    school = create(:school, weeks: [internship_weeks[1]])
    blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates - 1,
                                                            week: internship_weeks[0])

    not_blocked_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
    internship_offer = create(:weekly_internship_offer, published_at: Time.now, max_candidates: max_candidates,
                                                        internship_offer_weeks: [blocked_internship_week,
                                                                                 not_blocked_internship_week])
    

    sign_in(create(:student, school: school))

    InternshipOffer.stub :nearby, InternshipOffer.all do
      get internship_offers_path, params: { format: :json }
      assert_json_presence_of(json_response, internship_offer)
    end
  end

  test 'GET #index as student with page, returns paginated content' do
    # Api offers are ordered by creation date, so we can't test pagination with cities
    travel_to(Date.new(2019, 3, 1)) do
      # Student school is in Paris
      sign_in(create(:student))
      internship_offers = (InternshipOffer::PAGE_SIZE).times.map do
        create(:api_internship_offer, coordinates: Coordinates.bordeaux, city: 'Bordeaux')
      end
      # this one is in Paris, but it's the last one
      create(:api_internship_offer)
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        InternshipOffer.stub :in_the_future, InternshipOffer.all do
          get internship_offers_path, params: { format: :json }
          json_response.first[1].each do |internship_offer|
            assert_equal 'Bordeaux', internship_offer['city']
          end
          assert_equal InternshipOffer::PAGE_SIZE, json_response.first[1].count

          get internship_offers_path(page: 2, format: :json)
          assert_equal 1, json_response.first[1].count
          assert_equal 'Paris', json_response.first[1][0]['city']
        end
      end
    end
  end

  test 'GET #index as student with InternshipOffers::Api, returns paginated content' do
    travel_to(Date.new(2019, 3, 1)) do
      internship_offers = (InternshipOffer::PAGE_SIZE).times.map do
        create(:api_internship_offer)
      end
      create(:api_internship_offer, coordinates: Coordinates.bordeaux, city: 'Bordeaux')
      sign_in(create(:student))
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        InternshipOffer.stub :in_the_future, InternshipOffer.all do
          get internship_offers_path, params: { format: :json }
          json_response.first[1].each do |internship_offer|
            assert_equal 'Paris', internship_offer['city']
          end
          assert_equal InternshipOffer::PAGE_SIZE, json_response.first[1].count

          get internship_offers_path(page: 2, format: :json)
          assert_equal 1, json_response.first[1].count
          assert_equal 'Bordeaux', json_response.first[1][0]['city']
        end
      end
    end
  end

  test 'search by location (radius) works' do
    internship_offer_at_paris = create(:weekly_internship_offer,
                                       coordinates: Coordinates.paris)
    internship_offer_at_verneuil = create(:weekly_internship_offer,
                                          coordinates: Coordinates.verneuil)

    get internship_offers_path(latitude: Coordinates.paris[:latitude],
                               longitude: Coordinates.paris[:longitude],
                               radius: 60_000,
                               format: :json)
    assert_json_presence_of(json_response, internship_offer_at_verneuil)
    assert_json_presence_of(json_response, internship_offer_at_paris)

    get internship_offers_path(latitude: Coordinates.verneuil[:latitude],
                               longitude: Coordinates.verneuil[:longitude],
                               radius: 5_000,
                               format: :json)
    assert_json_presence_of(json_response, internship_offer_at_verneuil)
    assert_json_absence_of(json_response, internship_offer_at_paris)
  end

  test 'GET #index?latitude=?&longitude=? as student returns internship_offer 60km around this location' do
    travel_to(Date.new(2019, 3, 1)) do
      week = Week.find_by(year: 2019, number: 10)
      school_at_paris = create(:school, :at_paris)
      student = create(:student, school: school_at_paris)
      internship_offer_at_paris = create(:weekly_internship_offer,
                                        weeks: [week],
                                        coordinates: Coordinates.paris)
      internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                            weeks: [week],
                                            coordinates: Coordinates.bordeaux)

      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        sign_in(student)
      
        get internship_offers_path(latitude: Coordinates.bordeaux[:latitude],
                                   longitude: Coordinates.bordeaux[:longitude],
                                    format: :json)
        assert_response :success
        assert_json_absence_of(json_response, internship_offer_at_paris)
        assert_json_presence_of(json_response, internship_offer_at_bordeaux)
      end
    end
  end

  test 'GET #index as student ignores internship_offer farther than 60 km nearby school coordinates' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_bordeaux = create(:school, :at_bordeaux)
    student = create(:student, school: school_at_bordeaux)
    create(:weekly_internship_offer, weeks: [week],
                                     coordinates: Coordinates.paris)

    InternshipOffer.stub :by_weeks, InternshipOffer.all do
      sign_in(student)
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path, params: { format: :json }

        assert_response :success
        assert_select '.offer-row', 0
      end
    end
  end

  test 'GET #index as student not filtering by weeks shows all offers' do
    travel_to(Date.new(2019, 3, 1)) do
      week = Week.find_by(year: 2019, number: 10)
      school = create(:school, weeks: [week])
      student = create(:student, school: school,
                                class_room: create(:class_room, school: school))
      offer_overlaping_school_weeks = create(:weekly_internship_offer,
                                            weeks: [week])
      offer_not_overlaping_school_weeks = create(:weekly_internship_offer,
                                                weeks: [Week.find_by(
                                                  year: 2019, number: 11
                                                )])
      sign_in(student)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        assert_json_presence_of(json_response, offer_overlaping_school_weeks)
        assert_json_presence_of(json_response, offer_not_overlaping_school_weeks)
      end
    end
  end

  test 'GET #index as student filtering by weeks shows all offers' do
    travel_to(Date.new(2019, 12, 1)) do
      week = Week.find_by(year: 2020, number: 10)
      school = create(:school, weeks: [week])
      student = create(:student, school: school,
                                class_room: create(:class_room, school: school))
      offer_overlaping_school_weeks = create(:weekly_internship_offer,
                                            weeks: [week])

      refute offer_overlaping_school_weeks.shown_as_masked?
      offer_not_overlaping_school_weeks = create(:weekly_internship_offer,
                                                weeks: [Week.find_by(
                                                  year: 2020, number: 11
                                                )])
      sign_in(student)
      InternshipOffer.stub :nearby, InternshipOffer.all do
        get internship_offers_path(week_ids: school.week_ids, format: :json)

        assert_json_presence_of(json_response, offer_overlaping_school_weeks)
        assert_json_absence_of(json_response, offer_not_overlaping_school_weeks)
      end
    end
  end

  test 'GET #index as student ' \
       'ignores internship_offer restricted to school' \
       'finds internship_offer limited to current student school ' \
       'finds all internship_offers not limited' do
    student = create(:student, school: create(:school))
    sign_in(student)

    internship_limited_to_another_school = create(:weekly_internship_offer,
                                                  school: create(:school))
    internship_limited_to_student_school = create(:weekly_internship_offer,
                                                  school: student.school)
    internship_not_restricted_to_school = create(:weekly_internship_offer)

    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path, params: { format: :json }
        assert_json_presence_of(json_response, internship_not_restricted_to_school)
        assert_json_presence_of(json_response, internship_limited_to_student_school)
        assert_json_absence_of(json_response, internship_limited_to_another_school)
      end
    end
  end

  #
  # Employer
  #
  test 'GET #index as employer returns all internship offers' do
    employer = create(:employer)
    included_internship_offer = create(:weekly_internship_offer,
                                       employer: employer, title: 'Hellow-me')
    excluded_internship_offer = create(:weekly_internship_offer,
                                       title: 'Not hellow-me')
    sign_in(employer)
    get internship_offers_path, params: { format: :json }
    assert_response :success
    assert_json_presence_of(json_response, included_internship_offer)
    assert_json_presence_of(json_response, excluded_internship_offer)
  end

  test 'GET #index as god returns all internship_offers' do
    sign_in(create(:god))
    internship_offer_1 = create(:weekly_internship_offer, title: 'Hellow-me')
    internship_offer_2 = create(:weekly_internship_offer,
                                title: 'Not hellow-me')
    get internship_offers_path, params: { format: :json }
    assert_response :success
    assert_json_presence_of(json_response, internship_offer_1)
    assert_json_presence_of(json_response, internship_offer_2)
  end

  test 'GET #index as god. does not return discarded offers' do
    discarded_internship_offer = create(:weekly_internship_offer)
    discarded_internship_offer.discard
    god = create(:god)

    sign_in(god)
    get internship_offers_path, params: { format: :json }

    assert_response :success
    assert_select 'a[href=?]',
                  internship_offer_url(discarded_internship_offer), 0
  end

  test 'GET #index as Visitor with search keyword find internship offer' do
    keyword = 'foobar'
    foundable_internship_offer = create(:weekly_internship_offer,
                                        title: keyword)
    ignored_internship_offer = create(:weekly_internship_offer, title: 'bom')

    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now

    get internship_offers_path(keyword: keyword, format: :json)
    assert_response :success
    assert_json_presence_of(json_response, foundable_internship_offer)
    assert_json_absence_of(json_response, ignored_internship_offer)
  end
end
