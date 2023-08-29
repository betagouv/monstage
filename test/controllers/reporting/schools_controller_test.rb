# frozen_string_literal: true

require 'test_helper'

module Reporting
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    setup { create(:school) }

    test 'get index as visitor' do
      get reporting_schools_path
      assert_redirected_to root_path
    end

    test 'get index as Statistician' \
         'when department params match his departement_name' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_schools_path(department: statistician.department_name)
      assert_response :success
      assert_select 'title', "Statistiques sur les établissements | Monstage"
    end

    test 'get index.xlsx as Statistician' \
         'when department params match his departement_name' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_schools_path(department: statistician.department_name,
                                 format: :xlsx)
      assert_response :success
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_schools_path(department: 'Ain')
      assert_response 302
    end

    test 'GET #index as god success and it filters by susbcribed school'  do
      god = create(:god)
      school_without_manager = create(:school, name: 'school 1')
      school_with_manager    = create(:school, :with_school_manager,  name: 'school 2')
      sign_in(god)
      get reporting_schools_path
      assert_select  'tr.test-school-count', count: 3

      get reporting_schools_path(subscribed_school: 'all')
      assert_select  'tr.test-school-count', count: 3

      get reporting_schools_path(subscribed_school: 'false')
      assert_select  'tr.test-school-count', count: 2

      get reporting_schools_path(subscribed_school: 'true')
      assert_select  'tr.test-school-count', count: 1
    end



    test 'GET #index as operator works' do
      user_operator = create(:user_operator)
      sign_in(user_operator)
      get reporting_schools_path(department: 'Ain')
      assert_response 200
    end
  end
end
