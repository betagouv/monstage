
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
      paqte_group = create(:group, is_paqte: true)
      public_internship_offer = create(
        :weekly_internship_offer, # public internship by default
        zipcode: 75012 # Paris
      )
      public_internship_offer = create(
        :weekly_internship_offer, # public internship by default
        zipcode: 60580 # this zipcode belongs to Oise
      ) # 1 public Oise
      private_internship_offer = create(
        :weekly_internship_offer,
        :with_private_employer_group,
        group: paqte_group,
        max_candidates: 10,
        max_students_per_group: 10,
        zipcode: 60580
      ) # 10 paqte(private) Oise
      private_internship_offer_no_group = create(
        :weekly_internship_offer,
        is_public: false,
        group: nil,
        max_candidates: 20,
        max_students_per_group: 20,
        zipcode: 60580
      ) # 20 private Oise
      sign_in(statistician)

      # From now on, Oise only

      get reporting_employers_internship_offers_path(
        department: statistician.department_name,
        dimension: 'group'
      )
      assert_response :success
      assert_select 'title', "Statistiques par catégories d'entreprises | Monstage"

      # assert_select ".test-employer-#{public_internship_offer.group_id}", text: public_internship_offer.group.name
      # assert_select ".test-public-#{public_internship_offer.group_id}", text: 'Public'
      # assert_select ".test-published-offers-#{public_internship_offer.group_id}", text: '1'

      # assert_select ".test-employer-#{private_internship_offer.group_id}", text: private_internship_offer.group.name
      # assert_select ".test-public-#{private_internship_offer.group_id}", text: 'PaQte'
      # assert_select ".test-published-offers-#{private_internship_offer.group_id}", text: '10'

      # assert_select ".test-employer-", text: 'Indépendant'
      # assert_select ".test-public-", text: 'Privé'
      # assert_select ".test-published-offers-", text: '20'

      # private_internship_offer_no_group

      #private typology
      get reporting_employers_internship_offers_path(
        department: statistician.department_name,
        dimension: 'private_group'
      )
      assert_response :success

      # assert_select ".test-employer-#{public_internship_offer.group_id}", false
      # assert_select ".test-public-#{public_internship_offer.group_id}", false
      # assert_select ".test-published-offers-#{public_internship_offer.group_id}", false

      # assert_select ".test-employer-#{private_internship_offer.group_id}", text: private_internship_offer.group.name
      # assert_select ".test-public-#{private_internship_offer.group_id}", text: 'PaQte'
      # assert_select ".test-published-offers-#{private_internship_offer.group_id}", text: '10'

      # assert_select ".test-employer-", text: 'Indépendant'
      # assert_select ".test-public-", text: 'Privé'
      # assert_select ".test-published-offers-", text: '20'

      #public typology
      get reporting_employers_internship_offers_path(
        department: statistician.department_name,
        dimension: 'public_group'
      )
      assert_response :success
      # assert_select ".test-employer-#{public_internship_offer.group_id}", text: private_internship_offer.group.name
      # assert_select ".test-public-#{public_internship_offer.group_id}", text: 'Public'
      # assert_select ".test-published-offers-#{public_internship_offer.group_id}", text: '1'


      # assert_select ".test-employer-#{private_internship_offer.group_id}", false
      # assert_select ".test-public-#{private_internship_offer.group_id}", false
      # assert_select ".test-published-offers-#{private_internship_offer.group_id}", false

      # assert_select ".test-employer-", false
      # assert_select ".test-public-", false
      # assert_select ".test-published-offers-", false

      #paqte typology
      get reporting_employers_internship_offers_path(
        department: statistician.department_name,
        dimension: 'paqte_group'
      )
      assert_response :success
      # assert_select ".test-employer-#{public_internship_offer.group_id}", false
      # assert_select ".test-public-#{public_internship_offer.group_id}", false
      # assert_select ".test-published-offers-#{public_internship_offer.group_id}", false

      # assert_select ".test-employer-#{private_internship_offer.group_id}", text: private_internship_offer.group.name
      # assert_select ".test-public-#{private_internship_offer.group_id}", text: 'PaQte'
      # assert_select ".test-published-offers-#{private_internship_offer.group_id}", text: '10'

      # assert_select ".test-employer-", false
      # assert_select ".test-public-", false
      # assert_select ".test-published-offers-", false
    end

    test 'get index as MinistryStatistician'  do
      ministry_statistician = create(:ministry_statistician) # Oise is the department
      paqte_group = create(:group, is_paqte: true)
      public_internship_offer = create(
        :weekly_internship_offer, # public internship by default
        zipcode: 75012 # Paris
      )
      public_internship_offer = create(
        :weekly_internship_offer, # public internship by default
        group_id: ministry_statistician.ministries.first.id,
        zipcode: 60580 # this zipcode belongs to Oise
      ) # 1 public Oise
      private_internship_offer = create(
        :weekly_internship_offer,
        :with_private_employer_group,
        group: paqte_group,
        max_candidates: 10,
        max_students_per_group: 10,
        zipcode: 60580
      ) # 10 paqte(private) Oise
      private_internship_offer_no_group = create(
        :weekly_internship_offer,
        is_public: false,
        group: nil,
        max_candidates: 20,
        max_students_per_group: 20,
        zipcode: 60580
      ) # 20 private Oise
      sign_in(ministry_statistician)

      get reporting_dashboards_path
      assert_response :success
      assert_select 'title', "Statistiques - Tableau de bord | Monstage"
    end


    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_employers_internship_offers_path(department: 'Ain')
      assert_response 302
    end

    test 'GET #index as statistician works ' \
         'when department params does match his department and ' \
         'it filters results by department' do
      statistician = create(:statistician) #Oise
      public_internship_offer = create(
        :weekly_internship_offer,
        zipcode: 60580
      )
      private_internship_offer = create(
        :weekly_internship_offer,
        :with_private_employer_group,
        max_candidates: 10,
        max_students_per_group: 10,
        zipcode: 75001
      )
      private_internship_offer_no_group = create(
        :weekly_internship_offer,
        is_public: false,
        group: nil,
        max_candidates: 20,
        max_students_per_group: 20,
        zipcode: 60580
      )
      sign_in(statistician)

      get reporting_employers_internship_offers_path(
        department: statistician.department_name,
        dimension: 'group'
      )
      assert_response :success
      assert_select 'title', "Statistiques par catégories d'entreprises | Monstage"

      # assert_select ".test-employer-#{public_internship_offer.group_id}", text: public_internship_offer.group.name
      # assert_select ".test-public-#{public_internship_offer.group_id}", text: 'Public'
      # assert_select ".test-published-offers-#{public_internship_offer.group_id}", text: '1'

      # assert_select ".test-employer-#{private_internship_offer.group_id}", false
      # assert_select ".test-public-#{private_internship_offer.group_id}", false
      # assert_select ".test-published-offers-#{private_internship_offer.group_id}", false

      # assert_select ".test-employer-", text: 'Indépendant'
      # assert_select ".test-public-", text: 'Privé'
      # assert_select ".test-published-offers-", text: '20'
    end


    test 'GET #index as operator works' do
      user_operator = create(:user_operator)
      sign_in(user_operator)
      get reporting_employers_internship_offers_path
      assert_response 200
    end
  end
end
