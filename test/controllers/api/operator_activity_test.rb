require 'test_helper'

module Api
  class OperatorActivityTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers

    test "POST #create without token renders :unauthorized payload for operator_activity 's registration" do
      post create_account_api_operator_account_activities_path(params: {})
      documents_as(endpoint: :'internship_offers/create', state: :unauthorized) do
        assert_response :unauthorized
        assert_equal 'UNAUTHORIZED', json_code
        assert_equal 'wrong api token', json_error
      end
    end

    test "POST #create as operator fails with invalid student_data respond with :bad_request for operator_activity 's registration" do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      student = create(:student)
      assert_difference('OperatorActivity.count', 0) do
        documents_as(endpoint: :'operator_account_activities/create_account', state: :bad_request) do
          post create_account_api_operator_account_activities_path(
            params: {
              token: "Bearer #{operator.api_token}",
              remote_id: operator.operator.id,
              student_id: 151515 # invalid student id
            }
          )
        end
        assert_response :bad_request
      end

      assert_equal 'VALIDATION_ERROR', json_code
      assert_equal ['doit exister'], json_error['student'],
                   'bad operator message'

    end


    test "POST #create as operator fails with invalid data respond with :bad_request for operator_activity 's registration" do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      student = create(:student)
      assert_difference('OperatorActivity.count', 0) do
        documents_as(endpoint: :'operator_account_activities/create_account', state: :bad_request) do
          post create_account_api_operator_account_activities_path(
            params: {
              token: "Bearer #{operator.api_token}",
              operator_id: operator.operator.id, # bad key
              student_id: student.id
            }
          )
        end
        assert_response :bad_request
      end

      assert_equal 'VALIDATION_ERROR', json_code
      assert_equal ['doit exister'], json_error['operator'],
                   'bad operator message'
      assert_difference('OperatorActivity.count', 0) do
        documents_as(endpoint: :'operator_account_activities/create_account', state: :bad_request) do
          post create_account_api_operator_account_activities_path(
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

    test "POST #create as operator post duplicate remote_id for operator_activity's registration" do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      student = create(:student)
      OperatorActivity.create(
        operator_id: operator.operator.id,
        student_id: student.id,
        account_created: true
      )
      assert_no_difference('OperatorActivity.count') do
        documents_as(endpoint: :'operator_account_activities/create_account', state: :duplicated) do
          post create_account_api_operator_account_activities_path(
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

    test "POST #create_account as operator works for operator_activity's registration" do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      student = create(:student)
      assert_difference('OperatorActivity.count', 1) do
        documents_as(endpoint: :'operator_account_activities/create_account', state: :created) do
          post create_account_api_operator_account_activities_path(
            params: {
              token: "Bearer #{operator.api_token}",
              remote_id: operator.operator.id,
              student_id: student.id
            }
          )
        end
        assert_response :created
      end

      operator_activity = OperatorActivity.first
      assert_equal operator.operator.id, operator_activity.operator_id
      assert_equal student.id, operator_activity.student_id
      assert operator_activity.account_created

      assert_equal JSON.parse(operator_activity.to_json), json_response
    end
  end
end
