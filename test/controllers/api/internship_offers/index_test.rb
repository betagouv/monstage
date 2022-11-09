# frozen_string_literal: true

require 'test_helper'

module Api
  class IndexTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers

    test 'GET #index without token renders :unauthorized payload' do
      get api_internship_offers_path(params: {})
      documents_as(endpoint: :'internship_offers/index', state: :unauthorized) do
        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_code
        assert_equal 'wrong api token', json_error
      end
    end

    test 'GET #index without api_full_access renders :unauthorized payload' do
      user = create(:user_operator)
      operator = user.operator.update(api_full_access: false)

      documents_as(endpoint: :'internship_offers/index', state: :unauthorized) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}"
          }
        )

        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_code
        assert_equal 'access denied', json_error
      end
    end

    test 'GET #index without wrong params does not return error' do
      user = create(:user_operator)
      offer_1 = create(:weekly_internship_offer)

      documents_as(endpoint: :'internship_offers/index', state: :error) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}",
            page: 'not_a_number',
            wrong_params: 'string',
            coordinates: {
              one: 'aaa',
              two: 'bbb'
            },
            radius: 'abc'
          }
        )

        assert_response :success
        assert_equal 1, json_response['internshipOffers'].count
        assert_equal 1, json_response['pagination']['totalInternshipOffers']
        assert_equal 1, json_response['pagination']['totalPages']
        assert_equal true, json_response['pagination']['isFirstPage']
      end
    end

    test 'GET #index without params returns all internship_offers available' do
      user = create(:user_operator)
      offer_1 = create(:weekly_internship_offer)
      offer_2 = create(:weekly_internship_offer)
      offer_3 = create(:weekly_internship_offer, :unpublished)

      documents_as(endpoint: :'internship_offers/index', state: :success) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}"
          }
        )

        assert_response :success
        assert_equal 2, json_response['internshipOffers'].count
        assert_equal 2, json_response['pagination']['totalInternshipOffers']
        assert_equal 1, json_response['pagination']['totalPages']
        assert_equal true, json_response['pagination']['isFirstPage']
        assert_equal offer_1.id, json_response['internshipOffers'][1]['id']
        assert_equal offer_2.id, json_response['internshipOffers'][0]['id']
      end
    end

    test 'GET #index with page params returns the page results' do
      user = create(:user_operator)
      (InternshipOffer::PAGE_SIZE + 1).times { create(:weekly_internship_offer) }

      documents_as(endpoint: :'internship_offers/index', state: :success) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}",
            page: 2
          }
        )

        assert_response :success
        assert_equal 1, json_response['internshipOffers'].count
        assert_equal InternshipOffer::PAGE_SIZE + 1, json_response['pagination']['totalInternshipOffers']
        assert_equal 2, json_response['pagination']['totalPages']
      end
    end

    test 'GET #index with big page number params returns empty results' do
      user = create(:user_operator)
      (InternshipOffer::PAGE_SIZE + 1).times { create(:weekly_internship_offer) }

      documents_as(endpoint: :'internship_offers/index', state: :success) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}",
            page: 9
          }
        )

        assert_response :success
        assert_equal 0, json_response['internshipOffers'].count
        assert_equal InternshipOffer::PAGE_SIZE + 1, json_response['pagination']['totalInternshipOffers']
        assert_equal 2, json_response['pagination']['totalPages']
      end
    end



    test 'GET #index with coordinates params returns all internship_offers available in the city' do
      user = create(:user_operator)
      offer_1 = create(:weekly_internship_offer, city: 'Bordeaux', coordinates: { latitude: 44.8624, longitude: -0.5848 })
      offer_2 = create(:weekly_internship_offer)
      offer_3 = create(:weekly_internship_offer, :unpublished)

      documents_as(endpoint: :'internship_offers/index', state: :success) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}",
            latitude: 44.8624,
            longitude: -0.5848
          }
        )

        assert_response :success
        assert_equal 1, json_response['internshipOffers'].count
        assert_equal 1, json_response['pagination']['totalInternshipOffers']
        assert_equal 1, json_response['pagination']['totalPages']
        assert_equal true, json_response['pagination']['isFirstPage']
        assert_equal offer_1.id, json_response['internshipOffers'][0]['id']
      end
    end

    test 'GET #index with coordinates and radius params returns all internship_offers available in the radius' do
      user = create(:user_operator)
      offer_1 = create(:weekly_internship_offer, city: 'Bordeaux', coordinates: { latitude: 44.8624, longitude: -0.5848 })
      offer_2 = create(:weekly_internship_offer, city: 'Le Bouscat', coordinates: { latitude: 44.865, longitude: -0.6033 })
      offer_3 = create(:weekly_internship_offer, :unpublished)

      documents_as(endpoint: :'internship_offers/index', state: :success) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}",
            latitude: 44.8624,
            longitude: -0.5848,
            radius: 10000
          }
        )

        assert_response :success
        assert_equal 2, json_response['internshipOffers'].count
        assert_equal offer_2.id, json_response['internshipOffers'][0]['id']
        assert_equal offer_1.id, json_response['internshipOffers'][1]['id']
      end
    end

    test 'GET #index with coordinates and radius params returns all internship_offers available in the radis' do
      user = create(:user_operator)
      offer_1 = create(:weekly_internship_offer, city: 'Bordeaux', coordinates: { latitude: 44.8624, longitude: -0.5848 })
      offer_2 = create(:weekly_internship_offer, city: 'Le Bouscat', coordinates: { latitude: 44.865, longitude: -0.6033 })
      offer_3 = create(:weekly_internship_offer, :unpublished)

      documents_as(endpoint: :'internship_offers/index', state: :success) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}",
            latitude: 44.8624,
            longitude: -0.5848,
            radius: 1
          }
        )

        assert_response :success
        assert_equal 1, json_response['internshipOffers'].count
        assert_equal offer_1.id, json_response['internshipOffers'][0]['id']
      end
    end

    test 'GET #index with keyword params returns all internship_offers available in the radis' do
      user = create(:user_operator)
      offer_1 = create(:weekly_internship_offer, title: 'Chef de chantier')
      offer_2 = create(:weekly_internship_offer, title: 'Avocat')
      offer_3 = create(:weekly_internship_offer, title: 'Cheffe de cuisine')

      documents_as(endpoint: :'internship_offers/index', state: :success) do
        get api_internship_offers_path(
          params: {
            token: "Bearer #{user.api_token}",
            keyword: 'cuisine'
          }
        )

        assert_response :success
        assert_equal 1, json_response['internshipOffers'].count
        assert_equal offer_3.id, json_response['internshipOffers'][0]['id']
      end
    end
  end
end
