# frozen_string_literal: true

require 'test_helper'

module Reporting
  class DashboardsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'works' do
      get reporting_dashboards_path
      assert_response :success
    end
  end
end
