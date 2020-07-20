# frozen_string_literal: true

require 'test_helper'

module Reporting
  class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @sector_agri = create(:sector, name: 'Agriculture')
      @sector_wood = create(:sector, name: 'Filière bois')
      @internship_offer_agri_1 = create(:weekly_internship_offer, sector: @sector_agri, max_candidates: 1)
      @internship_offer_agri_2 = create(:weekly_internship_offer, sector: @sector_agri, max_candidates: 1)
      @internship_offer_wood = create(:weekly_internship_offer, sector: @sector_wood, max_candidates: 10)
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1)
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1)
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_2)
    end

    test 'GET #index not logged fails' do
      get reporting_internship_offers_path
      assert_response 302
    end

    test 'GET #index as GOD success' do
      god = create(:god)
      sign_in(god)
      create(:weekly_internship_offer)
      get reporting_internship_offers_path
      assert_response :success
    end

    test 'GET #index as statistician success ' \
         'when department params match his departement_name' do
      statistician = create(:statistician)
      department_name = statistician.department_name
      create(:weekly_internship_offer, department: department_name)
      sign_in(statistician)

      get reporting_internship_offers_path(department: department_name)
      assert_response :success
    end

    test 'GET #index.xlsx as statistician success ' \
         'when department params match his departement_name' do
      god = create(:god)
      create(:weekly_internship_offer)
      create(:api_internship_offer)
      sign_in(god)

      %i[offers group sector].each do |dimension|
        get(reporting_internship_offers_path(dimension: dimension,
                                             format: :xlsx))
        assert_response :success
      end
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department_name' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_internship_offers_path(department: 'Ain')
      assert_response 302
    end
  end
end
