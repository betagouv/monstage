require 'test_helper'

module Api
  class PartnerActivityTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers

    test "POST #create without token renders :unauthorized payload for partner_activity 's registration" do
      post create_account_api_partner_account_activities_path(params: {})
      documents_as(endpoint: :'internship_offers/create', state: :unauthorized) do
        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_code
        assert_equal 'wrong api token', json_error
      end
    end


    test "POST #create as operator fails with invalid data respond with :bad_request for partner_activity 's registration" do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      student = create(:student)
      assert_difference('PartnerActivity.count', 0) do
        documents_as(endpoint: :'partner_account_activities/create_account', state: :bad_request) do
          post create_account_api_partner_account_activities_path(
            params: {
              token: "Bearer #{operator.api_token}",
              operator_id: operator.operator.id, # BAD
              student_id: student.id
            }
          )
        end
        assert_response :bad_request
      end

      assert_equal 'VALIDATION_ERROR', json_code
      assert_equal ['doit exister'], json_error['operator'],
                   'bad operator message'
      assert_difference('PartnerActivity.count', 0) do
        documents_as(endpoint: :'partner_account_activities/create_account', state: :bad_request) do
          post create_account_api_partner_account_activities_path(
            params: {
              token: "Bearer #{operator.api_token}",
              remote_id: operator.operator.id, # BAD
              student_id: nil
            }
          )
        end
        assert_response :bad_request
      end

      assert_equal 'VALIDATION_ERROR', json_code
      assert_equal ['doit exister'], json_error['student'],
                   'bad student message'

    end

    test "POST #create as operator post duplicate remote_id for partner_activity's registration" do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      student = create(:student)
      PartnerActivity.create(
        operator_id: operator.operator.id,
        student_id: student.id,
        account_created: true
      )
      assert_no_difference('PartnerActivity.count') do
        documents_as(endpoint: :'partner_account_activities/create_account', state: :duplicated) do
          post create_account_api_partner_account_activities_path(
            params: {
              token: "Bearer #{operator.api_token}",
              remote_id: operator.operator.id,
              student_id: student.id
            }
          )
        end
        assert_response :conflict
      end
    end

    test "POST #create_account as operator works for partner_activity's registration" do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      student = create(:student)
      assert_difference('PartnerActivity.count', 1) do
        documents_as(endpoint: :'partner_account_activities/create_account', state: :created) do
          post create_account_api_partner_account_activities_path(
            params: {
              token: "Bearer #{operator.api_token}",
              remote_id: operator.operator.id,
              student_id: student.id
            }
          )
        end
        assert_response :created
      end

      partner_activity = PartnerActivity.first
      assert_equal operator.operator.id, partner_activity.operator_id
      assert_equal student.id, partner_activity.student_id
      assert partner_activity.account_created

      assert_equal JSON.parse(partner_activity.to_json), json_response
    end
  end
end