require 'test_helper'

module Api
  class CreateTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers
    test 'POST #create as operator with no error' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      internship_offer = create(:api_internship_offer)
      student = create(:student)

      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('ApplicationTracking.count', 1) do
          documents_as(endpoint: :'application_trackings/create', state: :created) do
            post api_application_trackings_path(
              params: {
                token: "Bearer #{operator.api_token}",
                application_tracking: {
                  remote_id: internship_offer.remote_id,
                  ms3e_student_id: student.id,
                  remote_status: 'application_submitted'
                }
              }
            )
          end
          assert_response :created
          application_tracking = Api::ApplicationTracking.first
          assert_equal internship_offer.id, application_tracking.internship_offer_id
          assert_equal student.id, application_tracking.student_id
          assert_equal 'application_submitted', application_tracking.remote_status
          assert_equal DateTime.now.to_date, application_tracking.application_submitted_at.to_date
          assert_equal JSON.parse(application_tracking.to_json), json_response
        end
      end
    end

    test 'POST #create as operator with duplicate error' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      internship_offer = create(:api_internship_offer)
      student = create(:student)
      parameters = {
        application_tracking: {
          remote_id: internship_offer.remote_id,
          ms3e_student_id: student.id,
          remote_status: 'application_submitted'
        }
      }

      travel_to(Date.new(2019, 3, 1)) do
        post api_application_trackings_path(
          params: {
            token: "Bearer #{operator.api_token}",
            **parameters
          }
        )
        application_tracking = Api::ApplicationTracking.first
        refute_nil application_tracking
        documents_as(endpoint: :'application_trackings/duplicate', state: :conflict) do
          post api_application_trackings_path(
            params: {
              token: "Bearer #{operator.api_token}",
              **parameters
            }
          )
          assert_equal 1, Api::ApplicationTracking.count
          assert_equal 'DUPLICATE_APPLICATION_TRACKING', json_response.to_hash.fetch('code')
          assert_equal "application_tracking with these attributes (internship_offer_id : #{internship_offer.id} | student_id : #{student.id} | application_submitted_at : 2019-03-01 00:00:00 +0100 | ms3e_student_id : #{student.id} | remote_status : application_submitted) already exists",
                       json_response.to_hash.fetch('error')
        end
      end
    end

    test 'POST #create as operator with validation error' do
      operator = create(:user_operator, api_token: SecureRandom.uuid)
      internship_offer = create(:api_internship_offer)
      student = create(:student)
      faulty_remote_status = 'application_submitted_xxxx'
      parameters = {
        application_tracking: {
          remote_id: internship_offer.remote_id,
          ms3e_student_id: student.id,
          remote_status: faulty_remote_status
        }
      }

      travel_to(Date.new(2019, 3, 1)) do
        assert_difference('ApplicationTracking.count', 0) do
          documents_as(endpoint: :'application_trackings/bad_request', state: :bad_request) do
            post api_application_trackings_path(
              params: {
                token: "Bearer #{operator.api_token}",
                **parameters
              }
            )
            assert_equal 'BAD_ARGUMENT', json_response.to_hash.fetch('code')
            assert_equal "'#{faulty_remote_status}' is not a valid remote_status",
                        json_response.to_hash.fetch('error')
          end
        end
      end
    end
  end
end