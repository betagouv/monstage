require 'test_helper'

module Services
  class SyncEmailDeliveryTest < ActiveSupport::TestCase
    test 'destroy_contact should destroy contact when contact exists' do
      sync = Services::SyncEmailDelivery.new
      expected_id = 'user_id'
      email_parameter = { email: 'test@test.fr' }

      fake_user_id = Minitest::Mock.new
      fake_response = OpenStruct.new(
        body: JSON.generate(
          { Data: [ID: expected_id], Count: 1 }.with_indifferent_access
        )
      )
      fake_user_id.expect :call, fake_response, [ email_parameter ]
      fake_response = Minitest::Mock.new
      fake_response.expect :call,
                           OpenStruct.new(code: 200),
                           [ { mailjet_user_id: expected_id } ]
      sync.stub :send_read_contact, fake_user_id do
        sync.stub :send_destroy_contact, fake_response do
          assert_equal true, sync.destroy_contact(email_parameter)
        end
      end
    end

    test 'destroy_contact should raise an error when contact does not exist' do
      sync = Services::SyncEmailDelivery.new
      wrong_return_code = 404
      expected_id       = 'user_id'
      email_parameter = { email: 'test@test.fr' }

      fake_user_id = Minitest::Mock.new
      fake_user_id.expect :call,
                          { "ErrorInfo": "", "ErrorMessage": "Object not found", "StatusCode": 404 }.with_indifferent_access,
                          [ email_parameter ]

      fake_response = Minitest::Mock.new
      fake_response.expect :call,
                           OpenStruct.new(code: wrong_return_code, body: 'test'),
                           [ { mailjet_user_id: expected_id } ]

      sync.stub :send_read_contact, fake_user_id do
        assert_raises(StandardError, "unknown email : test@test.fr - contact destroy impossible") do
          sync.destroy_contact(email_parameter)
        end
      end
    end
  end
end
