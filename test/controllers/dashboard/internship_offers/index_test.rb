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
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{internship_offer.id}"
    end

    test 'GET #index as Employer' do
      employer = create(:employer)
      internship_offer_published = create(:internship_offer, employer: employer)
      internship_offer_unpublished = create(:internship_offer, employer: employer)
      internship_offer_unpublished.update_column(:published_at, nil)
      sign_in(employer)
      get dashboard_internship_offers_path
      assert_select ".test-internship-offer-#{internship_offer_published.id}"
      assert_select ".test-internship-offer-#{internship_offer_unpublished.id}"
    end

    test 'GET #index as Employer show view_count' do
      internship_offer = create(:internship_offer, view_count: 10)

      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path

      assert_response :success
      assert_select ".test-internship-offer-#{internship_offer.id} .badge-view-count",
                    text: internship_offer.view_count.to_s,
                    count: 1
    end

    test 'GET #index returns sortable table' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offers_path
      assert_select 'a[href=?]', dashboard_internship_offers_path(order: 'view_count', direction: 'asc')
    end

    test 'GET #index with order & direction works' do
      employer = create(:employer)
      internship_offer_1 = create(:internship_offer, view_count: 2, employer: employer)
      internship_offer_2 = create(:internship_offer, view_count: 1, employer: employer)
      sign_in(employer)
      get dashboard_internship_offers_path(order: :view_count, direction: :desc)
      assert_select 'a.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :desc), count: 1
      assert_select 'a.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :asc), count: 0
      assert_select 'table tbody tr:first .internship-item-title', text: internship_offer_1.title
      assert_select 'table tbody tr:last .internship-item-title', text: internship_offer_2.title
      get dashboard_internship_offers_path(order: :view_count, direction: :asc)
      assert_select 'a.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :asc), count: 1
      assert_select 'a.active[href=?]', dashboard_internship_offers_path(order: :view_count, direction: :desc), count: 0
      assert_select 'table tbody tr:last .internship-item-title', text: internship_offer_1.title
      assert_select 'table tbody tr:first .internship-item-title', text: internship_offer_2.title
    end

    test 'GET #index with order success with all valid column' do
      employer = create(:employer)
      internship_offer_1 = create(:internship_offer, view_count: 2, employer: employer)
      internship_offer_2 = create(:internship_offer, view_count: 1, employer: employer)
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
      void_internship_offer = create(:internship_offer, employer: employer)
      internship_offer_with_pending_response = create(:internship_offer, employer: employer)
      create(:internship_application, :submitted,
             internship_offer: internship_offer_with_pending_response)
      internship_offer_with_application = create(:internship_offer, employer: employer)
      create(:internship_application, :approved,
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
      discarded_internship_offer = create(:internship_offer, :discarded, employer: employer)
      kept_internship_offer = create(:internship_offer, employer: employer)
      create(:internship_application, :submitted,
             internship_offer: discarded_internship_offer)
      create(:internship_application, :submitted,
             internship_offer: kept_internship_offer)
      create(:internship_application, :approved,
             internship_offer: kept_internship_offer)

      sign_in(employer)
      get dashboard_internship_offers_path

      assert_select '.warning-pending-notifications',
                    text: 'Vous avez 1 candidature(s) en attente de réponse.',
                    count: 1
    end

    test 'GET #index as Operator displays internship_applications link' do
      operator = create(:user_operator)
      another_internship_offer = create(:internship_offer)
      internship_offer_owned_by_operator = create(:internship_offer, employer: operator)
      internship_offer_delegated_to_opereator = create(:internship_offer, operators: [operator.operator])
      sign_in(operator)
      get dashboard_internship_offers_path
      assert_response :success
      assert_select "tr.test-internship-offer-#{another_internship_offer.id}",
                    count: 0
      assert_select "tr.test-internship-offer-#{internship_offer_owned_by_operator.id}",
                    count: 1
      assert_select "tr.test-internship-offer-#{internship_offer_delegated_to_opereator.id}",
                    count: 1
      assert_select 'a[href=?]', edit_dashboard_internship_offer_path(internship_offer_delegated_to_opereator),
                    count: 0
      assert_select 'a[href=?]', internship_offer_path(internship_offer_delegated_to_opereator),
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
      internship_offer_at_paris = create(:internship_offer, employer: operator, coordinates: Coordinates.paris)
      internship_offer_at_bordeaux = create(:internship_offer, employer: operator, coordinates: Coordinates.bordeaux)
      sign_in(operator)
      location_filter = { latitude: Coordinates.bordeaux[:latitude],
                          longitude: Coordinates.bordeaux[:longitude],
                          radius: 1_000 }

      get dashboard_internship_offers_path(location_filter)
      assert_response :success
      assert_absence_of(internship_offer: internship_offer_at_paris)
      assert_presence_of(internship_offer: internship_offer_at_bordeaux)

      ordonencer_options = { order: :title, direction: :desc }
      ordonencer_params = ordonencer_options.merge(location_filter)
      assert_select "a.sort-link[href=\"#{dashboard_internship_offers_path(ordonencer_params)}\"]",
                    1,
                    'ordonencer links should contain geo filters'
    end
  end
end
