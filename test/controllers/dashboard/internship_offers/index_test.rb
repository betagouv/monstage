# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def assert_presence_of(internship_offer:)
      assert_select "tr.test-internship-offer-#{internship_offer.id}", 1
    end

    def assert_absence_of(internship_offer:)
      assert_select "tr.test-internship-offer-#{internship_offer.id}", 0
    end

    test 'GET #index as Employer displays internship_applications link' do
      internship_offer = create(:weekly_internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select 'title', "Mes offres | Monstage"
      assert_select "tr.test-internship-offer-#{internship_offer.id}"
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

    test 'GET #index tabs forward expected params' do
      sign_in(create(:employer))

      forwarded_to_tabs_links = {
        latitude: Coordinates.bordeaux[:latitude],
        longitude: Coordinates.bordeaux[:longitude],
        radius: 1_000,
        city: 'bingobangobang',
        order: 'total_applications_count',
        direction: 'desc'
      }
      get dashboard_internship_offers_path(forwarded_to_tabs_links)
      assert_select 'a.nav-link[href=?]', dashboard_internship_offers_path({ filter: 'unpublished' }.merge(forwarded_to_tabs_links))
      assert_select 'a.nav-link[href=?]', dashboard_internship_offers_path({ filter: 'past' }.merge(forwarded_to_tabs_links))
      assert_select 'a.nav-link[href=?]', dashboard_internship_offers_path(forwarded_to_tabs_links)
    end

    test 'GET #index without filter as Employer show published and unpublished, not in past' do
      employer = create(:employer)
      internship_offer_published = create(:weekly_internship_offer, employer: employer)
      internship_offer_unpublished = create(:weekly_internship_offer, employer: employer)
      internship_offer_unpublished.update_column(:published_at, nil)
      internship_offer_in_the_past = create(
        :weekly_internship_offer,
        employer: employer,
        weeks: [Week.where(number: Date.today.cweek - 2,
                           year: Date.today.year)
                    .first]
      )
      sign_in(employer)

      get dashboard_internship_offers_path
      assert_select(".test-internship-offer-#{internship_offer_published.id}",
                    { count: 1 },
                    'should not have found published offer')
      assert_select(".test-internship-offer-#{internship_offer_unpublished.id}",
                    { count: 0 },
                    'should found unpublished offer')
      assert_select(".test-internship-offer-#{internship_offer_in_the_past.id}",
                    { count: 0 },
                    'should not have found offer in the past')
    end

    test 'GET #index with filter=unpublished as Employer show unpublished offers only' do
      employer = create(:employer)
      internship_offer_published = create(:weekly_internship_offer, employer: employer)
      internship_offer_unpublished = create(:weekly_internship_offer, employer: employer)
      internship_offer_unpublished.update_column(:published_at, nil)
      internship_offer_in_the_past = create(
        :weekly_internship_offer,
        employer: employer,
        weeks: [Week.where(number: Date.today.cweek - 2,
                           year: Date.today.year)
                    .first]
      )
      sign_in(employer)
      get dashboard_internship_offers_path(filter: :unpublished)
      assert_select(".test-internship-offer-#{internship_offer_published.id}",
                    { count: 0 },
                    'should not have found published offer')
      assert_select(".test-internship-offer-#{internship_offer_unpublished.id}",
                    { count: 1 },
                    'should found unpublished offer')
      assert_select(".test-internship-offer-#{internship_offer_in_the_past.id}",
                    { count: 0 },
                    'should not have found offer in the past')
    end

    test 'GET #index with filter=past as Employer show unpublished offers only' do
      employer = create(:employer)
      internship_offer_published = create(:weekly_internship_offer, employer: employer)
      internship_offer_unpublished = create(:weekly_internship_offer, employer: employer)
      internship_offer_unpublished.update_column(:published_at, nil)
      internship_offer_in_the_past = create(
        :weekly_internship_offer,
        employer: employer,
        weeks: [Week.where(number: Date.today.cweek - 2,
                           year: Date.today.year)
                    .first]
      )
      sign_in(employer)
      get dashboard_internship_offers_path(filter: :past)
      assert_select(".test-internship-offer-#{internship_offer_published.id}",
                    { count: 0 },
                    'should not have found published offer')
      assert_select(".test-internship-offer-#{internship_offer_unpublished.id}",
                    { count: 0 },
                    'should found unpublished offer')
      assert_select(".test-internship-offer-#{internship_offer_in_the_past.id}",
                    { count: 1 },
                    'should not have found offer in the past')
    end

    test 'GET #index as Employer show view_count' do
      internship_offer = create(:weekly_internship_offer, view_count: 10)

      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path

      assert_response :success
      assert_select ".test-internship-offer-#{internship_offer.id} .badge-view-count",
                    text: internship_offer.view_count.to_s,
                    count: 1
    end

    test 'GET #index returns sortable table' do
      internship_offer = create(:weekly_internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_select 'a[href=?]', dashboard_internship_offers_path(order: 'view_count', direction: 'asc')
    end

    test 'GET #index with order & direction works' do
      employer = create(:employer)
      internship_offer_1 = create(:weekly_internship_offer, view_count: 2, employer: employer)
      internship_offer_2 = create(:weekly_internship_offer, view_count: 1, employer: employer)
      sign_in(employer)
      get dashboard_internship_offers_path(order: :view_count, direction: :desc)
      assert_select 'a.sort-link.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :desc), count: 1
      assert_select 'a.sort-link.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :asc), count: 0
      assert_select 'table tbody tr:first .internship-item-title', text: internship_offer_1.title
      assert_select 'table tbody tr:last .internship-item-title', text: internship_offer_2.title
      get dashboard_internship_offers_path(order: :view_count, direction: :asc)
      assert_select 'a.sort-link.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :asc), count: 1
      assert_select 'a.sort-link.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :desc), count: 0
      assert_select 'table tbody tr:last .internship-item-title', text: internship_offer_1.title
      assert_select 'table tbody tr:first .internship-item-title', text: internship_offer_2.title
    end

    test 'GET #index with order success with all valid column' do
      employer = create(:employer)
      internship_offer_1 = create(:weekly_internship_offer, view_count: 2, employer: employer)
      internship_offer_2 = create(:weekly_internship_offer, view_count: 1, employer: employer)
      sign_in(employer)
      Dashboard::InternshipOffersController::VALID_ORDER_COLUMNS.map do |column|
        get dashboard_internship_offers_path(order: column, direction: :desc)
        assert_response :success
      end

      get dashboard_internship_offers_path(order: 'bimg', direction: :desc)
      assert_response :redirect
    end

    test 'GET #index as Employer displays links to internship_application' do
      employer = create(:employer)
      void_internship_offer = create(:weekly_internship_offer, employer: employer)
      internship_offer_with_pending_response = create(:weekly_internship_offer, employer: employer)
      create(:weekly_internship_application, :submitted,
             internship_offer: internship_offer_with_pending_response)
      internship_offer_with_application = create(:weekly_internship_offer, employer: employer)
      create(:weekly_internship_application, :approved,
             internship_offer: internship_offer_with_application)

      sign_in(employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select '.test-internship-offer', count: 3
      assert_select 'a[href=?]', dashboard_internship_offer_internship_applications_path(void_internship_offer), text: 'Répondre', count: 0
      assert_select 'a[href=?]', dashboard_internship_offer_internship_applications_path(void_internship_offer), text: 'Afficher', count: 0
      assert_select 'a[href=?]', dashboard_internship_offer_internship_applications_path(internship_offer_with_pending_response), text: 'Répondre'
      assert_select 'a[href=?]', dashboard_internship_offer_internship_applications_path(internship_offer_with_application), text: 'Afficher'
    end

    test 'GET #index as Employer displays pending submitted applications for kept internship_offers only' do
      employer = create(:employer)
      discarded_internship_offer = create(:weekly_internship_offer, :discarded, employer: employer)
      kept_internship_offer = create(:weekly_internship_offer, employer: employer)
      create(:weekly_internship_application, :submitted,
             internship_offer: discarded_internship_offer)
      create(:weekly_internship_application, :submitted,
             internship_offer: kept_internship_offer)
      create(:weekly_internship_application, :approved,
             internship_offer: kept_internship_offer)

      sign_in(employer)
      get dashboard_internship_offers_path

      assert_select '.warning-pending-notifications',
                    text: 'Vous avez 1 candidature(s) en attente de réponse.',
                    count: 1
    end

    test 'GET #index as Operator displays internship_applications link' do
      operator_1 = create(:user_operator)
      operator_2 = create(:user_operator)
      internship_offer_owned_by_operator = create(:weekly_internship_offer, employer: operator_1)
      another_internship_offer = create(:weekly_internship_offer, employer: operator_2)
      sign_in(operator_1)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{another_internship_offer.id}",
                    count: 0
      assert_select "tr.test-internship-offer-#{internship_offer_owned_by_operator.id}",
                    count: 1
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

    test 'GET #index as Operator works with geolocaton params' do
      operator = create(:user_operator)
      internship_offer_at_paris = create(:weekly_internship_offer, employer: operator, coordinates: Coordinates.paris)
      internship_offer_at_bordeaux = create(:weekly_internship_offer, employer: operator, coordinates: Coordinates.bordeaux)
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

      sort_params = { order: :title, direction: :desc }
      ordonencer_params = sort_params.merge(location_params_forwarded_to_sort_links)
      assert_select "a.sort-link[href=\"#{dashboard_internship_offers_path(ordonencer_params)}\"]",
                    1,
                    'ordonencer links should contain geo filters'
    end
  end
end
