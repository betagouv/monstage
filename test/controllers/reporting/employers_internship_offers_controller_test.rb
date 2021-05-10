
require 'test_helper'

module Reporting
  class EmployersInternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'get index as visitor' do
      get reporting_employers_internship_offers_path
      assert_redirected_to root_path
    end

    test 'get index as Statistician' \
         'when department params match his departement_name' do
      statistician = create(:statistician) # Oise is the department
      public_internship_offer = create(
        :troisieme_generale_internship_offer,
        zipcode: 60580
      )
      private_internship_offer = create(
        :troisieme_generale_internship_offer,
        :with_private_employer_group,
        max_candidates: 10,
        zipcode: 60580
      )
      private_internship_offer_no_group = create(
        :troisieme_generale_internship_offer,
        is_public: false,
        group: nil,
        max_candidates: 20,
        zipcode: 60580
      )
      sign_in(statistician)

      get reporting_employers_internship_offers_path(
        department: statistician.department,
        dimension: 'entreprise'
      )
      assert_response :success
      assert_select 'title', "Statistiques par catégories d'entreprises | Monstage"

      assert_select ".test-employer-#{public_internship_offer.group_id}", text: public_internship_offer.group.name
      assert_select ".test-public-#{public_internship_offer.group_id}", text: 'Public'
      assert_select ".test-published-offers-#{public_internship_offer.group_id}", text: '1'

      assert_select ".test-employer-#{private_internship_offer.group_id}", text: private_internship_offer.group.name
      assert_select ".test-public-#{private_internship_offer.group_id}", text: 'PaQte'
      assert_select ".test-published-offers-#{private_internship_offer.group_id}", text: '10'

    end

    # test 'get index.xlsx as Statistician' \
    #      'when department params match his departement_name' do
    #   statistician = create(:statistician)
    #   sign_in(statistician)
    #   get reporting_schools_path(department: statistician.department,
    #                              format: :xlsx)
    #   assert_response :success
    # end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_employers_internship_offers_path(department: 'Ain')
      assert_response 302
    end
  end
end