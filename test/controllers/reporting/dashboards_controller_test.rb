# frozen_string_literal: true

require 'test_helper'

module Reporting
  class DashboardsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #index not logged fails' do
      get reporting_dashboards_path
      assert_response 302
    end

    test 'GET #index as GOD success' do
      god = create(:god)
      sign_in(god)
      get reporting_dashboards_path
      assert_response :success
    end

    test 'GET #index as statistician success ' \
         'when department params match his departement_name' do
      statistician = create(:statistician)
      zipcode = "#{statistician.department_zipcode}000"
      school_without_manager = create(
        :school,
        weeks: weeks,
        zipcode: zipcode
      )
      school_with_manager = create(
        :school,
        :with_school_manager,
        weeks: weeks,
        zipcode: zipcode
      )

      sign_in(statistician)
      get reporting_dashboards_path(department: statistician.department_name)
      assert_response :success
      assert_select "#test-school-without-manager-#{school_without_manager.id}"
      assert_select "#test-school-with-manager-#{school_with_manager.id}"
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department_name' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_dashboards_path(department: 'Ain')
      assert_response 302
      assert_redirected_to root_path
    end
  end
end
