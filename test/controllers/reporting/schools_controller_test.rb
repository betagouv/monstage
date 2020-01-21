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
         "when department params match his departement_name" do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_schools_path(department: statistician.department_name)
      assert_response :success
    end

    test 'get index.xlsx as Statistician' \
         "when department params match his departement_name" do
      statistician = create(:statistician)
        sign_in(statistician)
      get reporting_schools_path(department: statistician.department_name,
                                 format: :xlsx)
      assert_response :success
    end

    test "GET #index as statistician fails " \
         "when department params does not match his department_name" do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_schools_path(department: 'Ain')
      assert_response 302
    end
  end
end
