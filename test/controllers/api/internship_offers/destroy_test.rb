# frozen_string_literal: true

require 'test_helper'

module Api
  class DestroyTest < ActionDispatch::IntegrationTest
    include ApiTestHelpers

    setup do
      @operator = create(:user_operator)
      @internship_offer = create(:api_internship_offer, employer: @operator)
    end

    test 'DELETE #destroy without token renders :unauthorized payload' do
      documents_as(endpoint: :'internship_offers/destroy', state: :unauthorized) do
        delete api_internship_offer_path(id: @internship_offer.remote_id)
      end
      assert_response :unauthorized
      assert_equal 'UNAUTHORIZED', json_response['code']
      assert_equal 'wrong api token', json_error
    end

    test 'DELETE #destroy an internship_offer which does not belongs to current auth operator' do
      bad_operator = create(:user_operator)
      documents_as(endpoint: :'internship_offers/destroy', state: :forbidden) do
        delete api_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{bad_operator.api_token}"
          }
        )
      end
      assert_response :forbidden
      assert_equal 'FORBIDDEN', json_response['code']
      assert_equal 'You are not authorized to access this page.', json_error
    end

    test 'DELETE #destroy as operator fails with invalid remote_id' do
      documents_as(endpoint: :'internship_offers/destroy', state: :not_found) do
        delete api_internship_offer_path(
          id: 'foo',
          params: {
            token: "Bearer #{@operator.api_token}"
          }
        )
      end
      assert_response :not_found
      assert_equal 'NOT_FOUND', json_response['code']
      assert_equal "can't find internship_offer with this remote_id", json_error
    end

    test 'DELETE #destroy as operator works to internship_offers' do
      documents_as(endpoint: :'internship_offers/destroy', state: :ok) do
        delete api_internship_offer_path(
          id: @internship_offer.remote_id,
          params: {
            token: "Bearer #{@operator.api_token}"
          }
        )
      end
      assert_response :ok
      assert_equal 0, InternshipOffer.kept.count
      assert InternshipOffer.last.discarded?
    end

    test 'DELETE #destroy twice renders conflict' do
      documents_as(endpoint: :'internship_offers/destroy', state: :conflict) do
        delete api_internship_offer_path(id: @internship_offer.remote_id,
                                         params: { token: "Bearer #{@operator.api_token}" })
        delete api_internship_offer_path(id: @internship_offer.remote_id,
                                         params: { token: "Bearer #{@operator.api_token}" })
      end
      assert_response :conflict
    end
  end
end
