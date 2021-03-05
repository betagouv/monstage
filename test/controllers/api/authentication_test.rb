# frozen_string_literal: true

require 'test_helper'

module Api
  class CreateTest < ActionDispatch::IntegrationTest
    include ::ApiTestHelpers
    setup do
      @operator = create(:user_operator)
    end

    def assert_not_unauthorized
      assert_not_equal '401', response.code.to_s, 'in any case response should not be 404'
      assert_equal '404', response.code.to_s, 'expect not found on destroy with unkown remote di'
    end

    test 'works with token param' do
      delete api_internship_offer_path(
        id: 'anything',
        params: {
          token: "Bearer #{@operator.api_token}"
        }
      )
      assert_not_unauthorized
    end

    test 'works with Authorization header' do
      delete(api_internship_offer_path(id: 'anything'),
             headers: {
               'Authorization' => "Bearer #{@operator.api_token}"
             })
      assert_not_unauthorized
    end
  end
end
