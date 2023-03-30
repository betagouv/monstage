# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class IndexTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def assert_presence_of(internship_offer:)
      assert_select "tr.test-internship-offer-#{internship_offer.id}", 1
    end

    def assert_absence_of(internship_offer:)
      assert_select "tr.test-internship-offer-#{internship_offer.id}", 0
    end

    def assert_data_presence_of(internship_offer:)
      assert_select "a[data-test-id='#{internship_offer.id}']",
                      count: 1
    end

    test 'GET #index as Employer displays internship_applications link' do
      internship_offer = create(:weekly_internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select 'title', 'Mes offres | Monstage'
      assert_presence_of(internship_offer: internship_offer)
    end

    test 'GET #index as employer returns his internship_offers' do
      employer = create(:employer)
      included_internship_offer = create(:weekly_internship_offer,
                                         employer: employer, title: 'Hellow-me')
      excluded_internship_offer = create(:weekly_internship_offer,
                                         title: 'Not hellow-me')
      sign_in(employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_presence_of(internship_offer: included_internship_offer)
      assert_absence_of(internship_offer: excluded_internship_offer)
    end

    test 'GET #index as employer returns his internship_offers with applications on them' do
      employer = create(:employer)
      included_internship_offer = create(:weekly_internship_offer,
                                         employer: employer, title: 'Hellow-me')
      excluded_internship_offer = create(:weekly_internship_offer,
                                         title: 'Not hellow-me')
      student = create(:student)
      internship_application = create( :weekly_internship_application,
                                       internship_offer: included_internship_offer,
                                       student: student )
      internship_application.submit!
      sign_in(employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_presence_of(internship_offer: included_internship_offer)
      assert_absence_of(internship_offer: excluded_internship_offer)
    end

    test 'GET #index with filters includes thoses filter in search form' do
      employer = create(:employer)
      sign_in(employer)
      filters = {
        direction: 'asc',
        filter: '2',
        order: 'approved_applications_count'
      }
      get dashboard_internship_offers_path(filters)
      assert_response :success
    end

    test 'GET #index as operator returns his internship_offers but not other offers even from similar operator' do
      operator = create(:operator)
      operator_2 = create(:operator)
      user_operator_1 = create(:user_operator, operator: operator)
      user_operator_1_bis = create(:user_operator, operator: operator)
      user_operator_2 = create(:user_operator, operator: operator_2)
      included_internship_offer_1 = create(:weekly_internship_offer,
                                           employer: user_operator_1)
      included_internship_offer_1_bis = create(:weekly_internship_offer,
                                               employer: user_operator_1_bis)
      excluded_internship_offer = create(:weekly_internship_offer,
                                         employer: user_operator_2)
      sign_in(user_operator_1)
      get dashboard_internship_offers_path
      assert_response :success
      assert_presence_of(internship_offer: included_internship_offer_1)
      assert_absence_of(internship_offer: included_internship_offer_1_bis)
      assert_absence_of(internship_offer: excluded_internship_offer)
    end

    test 'GET #index as operator not departement-constraint returns internship offer not considering location constraint' do
      operator = create(:operator)
      user_operator = create(:user_operator, operator: operator,
                                             department: nil)
      included_internship_offer = create(:weekly_internship_offer,
                                         employer: user_operator,
                                         zipcode: 60_580)
      excluded_internship_offer = create(:weekly_internship_offer,
                                         employer: user_operator,
                                         zipcode: 95_270)
      sign_in(user_operator)
      get dashboard_internship_offers_path
      assert_response :success
      assert_presence_of(internship_offer: included_internship_offer)
      assert_presence_of(internship_offer: excluded_internship_offer)
      assert_presence_of(internship_offer: excluded_internship_offer)
    end

    test 'GET #index as operator can filter by coordinates' do
      operator = create(:operator)
      user_operator = create(:user_operator, operator: operator,
                                             department: nil)
      excluded_internship_offer = create(:weekly_internship_offer, employer: user_operator,
                                                                   coordinates: Coordinates.paris)
      included_internship_offer = create(:weekly_internship_offer, employer: user_operator,
                                                                   coordinates: Coordinates.bordeaux)
      sign_in(user_operator)
      get dashboard_internship_offers_path(
        latitude: Coordinates.bordeaux[:latitude],
        longitude: Coordinates.bordeaux[:longitude]
      )
      assert_response :success
      assert_presence_of(internship_offer: included_internship_offer)
      assert_absence_of(internship_offer: excluded_internship_offer)
    end

    test 'GET #index as Visitor redirects to sign in path' do
      get dashboard_internship_offers_path
      assert_redirected_to user_session_path
    end

    test 'GET #index as Student is forbidden' do
      sign_in(create(:student))
      get dashboard_internship_offers_path
      assert_redirected_to root_path
    end

    # test 'week selection does not prevent from showing api offers' do
    #   travel_to(Date.new(2019, 9, 1)) do
    #     available_weeks = Week.selectable_on_school_year
    #     school_weeks = Week.selectable_on_school_year[0..2]
    #     school = create(:school, weeks: school_weeks)
    #     student = create(:student, school: school)
    #     internship_offer = create(:weekly_internship_offer, weeks: [school_weeks.first] )
    #     internship_offer_api = create(:api_internship_offer, weeks: [school_weeks.last] )
    #     week = internship_offer.internship_offer_weeks.first.week
    #     week_api = internship_offer_api.internship_offer_weeks.first.week
    #     sign_in(student)

    #     InternshipOffer.stub :nearby, InternshipOffer.all do
    #       get dashboard_internship_offers_path
    #       assert_data_presence_of(internship_offer: internship_offer)
    #       assert_data_presence_of(internship_offer: internship_offer_api)
    #       get internship_offers_path( week_ids: [week.id, week_api.id])
    #       assert_data_presence_of(internship_offer: internship_offer)
    #       assert_data_presence_of(internship_offer: internship_offer_api)
    #     end
    #   end
    # end

    test 'GET #index filters as Employer show published, unpublished, in past when required' do
      employer = create(:employer)
      internship_offer_published = create(:weekly_internship_offer,
                                          employer: employer)
      internship_offer_unpublished = create(:weekly_internship_offer,
                                            employer: employer)
      internship_offer_unpublished.update_column(:published_at, nil)
      two_weeks_ago = 2.weeks.ago
      internship_offer_in_the_past = create(
        :weekly_internship_offer,
        employer: employer,
        weeks: [Week.where(number: two_weeks_ago.to_date.cweek == 53 ? 1 : two_weeks_ago.to_date.cweek,
                           year: two_weeks_ago.year)
                    .first]
      )
      sign_in(employer)

      get dashboard_internship_offers_path

      assert_select(".test-internship-offer-#{internship_offer_published.id}",
                    { count: 1 },
                    'should not have found published offer')
      assert_select(".test-internship-offer-#{internship_offer_unpublished.id}",
                    { count: 1 },
                    'should found unpublished offer')
      assert_select(".test-internship-offer-#{internship_offer_in_the_past.id}",
                    { count: 1 },
                    'should not have found offer in the past')

    end

    test 'GET #index returns sortable table' do
      internship_offer = create(:weekly_internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_select 'a[href=?]',
                    dashboard_internship_offers_path(order: 'remaining_seats_count',
                                                     direction: 'desc')
    end

    test 'GET #index with order & direction works' do
      employer = create(:employer)
      travel_to(Date.new(2019, 9, 1)) do
        internship_offer_1 = create(:weekly_internship_offer,
                                    weeks: Week.selectable_from_now_until_end_of_school_year.first(2),
                                    max_candidates: 2,
                                    remaining_seats_count: 2,
                                    max_students_per_group: 2,
                                    employer: employer)
      internship_offer_2 = create(:weekly_internship_offer,
                                  max_candidates: 1,
                                  remaining_seats_count: 1,
                                  max_students_per_group: 1,
                                  employer: employer)
      sign_in(employer)
      get dashboard_internship_offers_path(order: :remaining_seats_count, direction: :desc)
      assert_select 'a[href=?]',
                    dashboard_internship_offers_path(order: :remaining_seats_count,
                                                     direction: :asc),
                    count: 1
      assert_select 'a.currently-sorting[href=?]',
                    dashboard_internship_offers_path(order: :remaining_seats_count, direction: :desc), count: 0
      assert_select 'table tbody tr:first .internship-item-title',
                    text: "#{internship_offer_1.title}#{internship_offer_1.city}"
      assert_select 'table tbody tr:last .internship-item-title',
                    text: "#{internship_offer_2.title}#{internship_offer_2.city}"
      get dashboard_internship_offers_path(order: :remaining_seats_count, direction: :asc)
      assert_select 'a.currently-sorting[href=?]',
                    dashboard_internship_offers_path(order: :remaining_seats_count, direction: :desc), count: 1
      assert_select 'a.currently-sorting[href=?]',
                    dashboard_internship_offers_path(order: :remaining_seats_count, direction: :asc), count: 0
      assert_select 'table tbody tr:last .internship-item-title',
                    text: "#{internship_offer_1.title}#{internship_offer_1.city}"
      assert_select 'table tbody tr:first .internship-item-title',
                    text: "#{internship_offer_2.title}#{internship_offer_2.city}"
      end
    end

    test 'GET #index with order success with all valid column' do
      employer = create(:employer)
      internship_offer_1 = create(:weekly_internship_offer, view_count: 2,
                                                            employer: employer)
      internship_offer_2 = create(:weekly_internship_offer, view_count: 1,
                                                            employer: employer)
      sign_in(employer)
      Dashboard::InternshipOffersController::VALID_ORDER_COLUMNS.map do |column|
        get dashboard_internship_offers_path(order: column, direction: :desc)
        assert_response :success
      end

      get dashboard_internship_offers_path(order: 'bimg', direction: :desc)
      assert_response :redirect
    end

    test 'GET #index as Employer displays pending submitted applications for kept internship_offers only' do
      travel_to(Date.new(2019, 9, 1)) do
        employer = create(:employer)
        discarded_internship_offer = create(:weekly_internship_offer,
                                            :discarded, employer: employer,
                                            max_candidates: 10,
                                            max_students_per_group: 5,
                                            weeks: Week.selectable_from_now_until_end_of_school_year.first(10))
        kept_internship_offer = create(:weekly_internship_offer,
                                      employer: employer,
                                      max_candidates: 10,
                                      max_students_per_group: 5,
                                      weeks: Week.selectable_from_now_until_end_of_school_year.first(10))
        create(:weekly_internship_application, :submitted,
              internship_offer: discarded_internship_offer)
        2.times do
          create(:weekly_internship_application, :submitted,
                internship_offer: kept_internship_offer)
        end
        3.times do
          create(:weekly_internship_application, :approved,
                internship_offer: kept_internship_offer)
        end

        sign_in(employer)
        get dashboard_internship_offers_path
        assert_select '.fr-badge.fr-badge--new',
                       text: '2',
                       count: 1
      end
    end

    test 'GET #index as Operator displays api_internship_offers' do
      operator = create(:user_operator)
      internship_offer = create(:api_internship_offer, employer: operator)
      sign_in(operator)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{internship_offer.id}",
                    count: 1
    end

    test 'GET #index as Operator works with geolocation params' do
      operator = create(:user_operator)
      internship_offer_at_paris = create(:weekly_internship_offer,
                                         employer: operator,
                                         coordinates: Coordinates.paris)
      internship_offer_at_bordeaux = create(:weekly_internship_offer,
                                            employer: operator,
                                            coordinates: Coordinates.bordeaux)
      sign_in(operator)

      location_params_forwarded_to_sort_links = {
        latitude: Coordinates.bordeaux[:latitude],
        longitude: Coordinates.bordeaux[:longitude],
        radius: 1_000,
        city: 'bingobangobang',
        filter: 'active'
      }
      get dashboard_internship_offers_path(location_params_forwarded_to_sort_links)
      assert_response :success
      assert_absence_of(internship_offer: internship_offer_at_paris)
      assert_presence_of(internship_offer: internship_offer_at_bordeaux)

      # Check sorting links on column header, like ... on title column
      sort_params = { order: :title, direction: :desc }
      ordonencer_params = sort_params.merge(location_params_forwarded_to_sort_links)
      assert_select "a.fr-raw-link[href='#{dashboard_internship_offers_path(ordonencer_params)}']",
                    1,
                    'ordonencer links should contain geo filters'
    end
  end
end
