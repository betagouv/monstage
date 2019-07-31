# frozen_string_literal: true

require 'test_helper'

module Api
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'search by term' do
      post search_api_schools_path, params: { term: "Un+pavais+dans+la+marre" }
      assert_response :success
    end
  end
end
