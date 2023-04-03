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

    test 'GET #index as operator fails' do
      user_operator = create(:user_operator)
      sign_in(user_operator)
      get reporting_dashboards_path(department: 'Ain')
      assert_response 302
      assert_redirected_to root_path
    end

    test 'GET #index as ministry statistician counts ' \
         'offers of his own administration' do
      ministry_statistician = create(:ministry_statistician)
      ministry_groups = ministry_statistician.ministries
      ministry_group = ministry_groups.first
      public_group = create(:public_group)
      private_group  = create(:private_group)
      strict_beginning_year = SchoolYear::Current.new.strict_beginning_of_period.year
      weeks_of_current_year = [::Week.fetch_from(date: Date.new(strict_beginning_year, 9, 8))]
      weeks_of_passed_year  = [::Week.fetch_from(date: Date.new(strict_beginning_year - 1, 9, 8))]
      current_year = strict_beginning_year
      last_year = current_year - 1

      assert ministry_group.is_public,
             'ministry_statistician associated group should have been public'
      # ministry internship offer with 1
      first_offer = create(
        :weekly_internship_offer,
        :troisieme_generale_internship_offer,
        weeks: weeks_of_current_year,
        group: ministry_group,
        is_public: true
      )

      # private independant internship_offer with 10
      create(
        :weekly_internship_offer,
        :troisieme_generale_internship_offer,
        max_candidates: 10,
        max_students_per_group: 10,
        group: nil,
        is_public: false
      )

      # private internship offer with 20
      create(
        :weekly_internship_offer,
        :troisieme_generale_internship_offer,
        max_candidates: 20,
        max_students_per_group: 20,
        group: private_group,
        is_public: false
      )

      sign_in(ministry_statistician)
      get reporting_dashboards_path
      assert_response 200
    end
  end
end
