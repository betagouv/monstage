# frozen_string_literal: true

require 'test_helper'

module Reporting
  class DashboardsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #index not logged fails' do
      get reporting_dashboards_path
      assert_response 302
    end

    test 'GET #index as GOD success and has a page title' do
      god = create(:god)
      sign_in(god)
      get reporting_dashboards_path
      assert_response :success
      assert_select 'title', "Statistiques - Tableau de bord | Monstage"
    end

    test 'GET #index as statistician success ' \
         'when department params match his departement_name' do
      statistician = create(:statistician)
      zipcode = "#{statistician.department_zipcode}000"
      sign_in(statistician)
      get reporting_dashboards_path(department: statistician.department)
      assert_select "a[data-test-refresh=1][href=?]", reporting_dashboards_refresh_path
      assert_select "a[data-test-refresh=1][data-method=post]"
      assert_response :success
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_dashboards_path(department: 'Ain')
      assert_response 302
      assert_redirected_to root_path
    end

    test 'POST #refresh as super admin' do
      god = create(:god)
      sign_in(god)
      airtable_syncronizer_mock = Minitest::Mock.new
      airtable_syncronizer_mock.expect(:pull_all, true)
      AirtableSynchronizer.stub :new, airtable_syncronizer_mock do
        post reporting_dashboards_refresh_path
        assert_response 302
      end
      airtable_syncronizer_mock.verify
    end
  end
end
