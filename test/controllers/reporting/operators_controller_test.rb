# frozen_string_literal: true

require 'test_helper'

module Reporting
  class OperatorsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    setup { create(:school) }

    test 'get index as visitor redirects to root' do
      get reporting_operators_path
      assert_redirected_to root_path
    end

    test 'get index as statisticians redirects to root' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_operators_path
      # TODO check why this test fails
      # assert_redirected_to root_path
    end

    test 'get index as god works' do
      god = create(:god)
      sign_in(god)
      operator_1 = create(:operator, name: 'operator 1')
      operator_2 = create(:operator, name: 'operator 2')

      get reporting_operators_path

      assert_response :success
      assert_select 'h1', "Statistiques associations"
      assert_select '.test-operator-count', count: 2
    end

    test 'get index.xls as god works' do
      god = create(:god)
      sign_in(god)
      get reporting_operators_path(format: :xlsx)
      assert_response :success
    end

    test 'PATCH #update as god success'  do
      god = create(:god)
      operator_1 = create(:operator, target_count: 0)
      sign_in(god)
      operator_params = {
        id: operator_1.id,
        target_count: 10,
        school_year: 2022,
        onsite_count: '50',
        online_count: '30',
        hybrid_count: '20',
        workshop_count: '10',
        private_count: '80',
        public_count: '20'
      }

      put reporting_operators_path, params: { operator: operator_params }

      assert_response :redirect
      assert_equal 10, operator_1.reload.target_count
      assert_equal 100, operator_1.reload.realized_count['2022']['total']
      assert_equal 50, operator_1.reload.realized_count['2022']['onsite']
      assert_equal 30, operator_1.reload.realized_count['2022']['online']
      assert_equal 20, operator_1.reload.realized_count['2022']['hybrid']
      assert_equal 10, operator_1.reload.realized_count['2022']['workshop']
      assert_equal 80, operator_1.reload.realized_count['2022']['private']
      assert_equal 20, operator_1.reload.realized_count['2022']['public']
    end
  end
end
