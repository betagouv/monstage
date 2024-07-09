# frozen_string_literal: true

require 'test_helper'

module Reporting
  class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @sector_agri = create(:sector, name: 'Agriculture')
      @sector_wood = create(:sector, name: 'Filière bois')
      @student_male1 = create(:student, :male)
      @student_male2 = create(:student, :male)
      @student_female1 = create(:student, :female)
      @group_with_no_offer = create(:group, name: "no offer", is_public: false)
      # Following will be discarded
      @internship_offer_agri_0 = create(:weekly_internship_offer,
                                        sector: @sector_agri,
                                        max_candidates: 1,
                                        discarded_at: Date.today,
                                        max_students_per_group: 1)
      @internship_offer_agri_1 = create(:weekly_internship_offer,
                                        sector: @sector_agri,
                                        max_candidates: 1,
                                        max_students_per_group: 1)
      @internship_offer_agri_2 = create(:weekly_internship_offer,
                                        sector: @sector_agri,
                                        max_candidates: 1,
                                        max_students_per_group: 1)
      @internship_offer_wood = create(:weekly_internship_offer,
                                      sector: @sector_wood,
                                      max_candidates: 10,
                                      max_students_per_group: 10)
      create(:weekly_internship_application,
             :submitted,
             internship_offer: @internship_offer_agri_1,
             student: @student_female1)
      create(:weekly_internship_application,
             :submitted,
             internship_offer: @internship_offer_agri_1,
             student: @student_male1)
      create(:weekly_internship_application,
             :submitted,
             internship_offer: @internship_offer_agri_2,
             student: @student_male2)
      create(:weekly_internship_application,
             :approved,
             internship_offer: @internship_offer_agri_1,
             student: @student_male2)
    end

    test 'GET #index not logged fails' do
      get reporting_internship_offers_path
      assert_response 302
    end

    test 'GET #index as GOD success and has a page title' do
      god = create(:god)
      sign_in(god)
      create(:weekly_internship_offer)
      get reporting_internship_offers_path
      assert_response :success
      assert_select 'title', "Statistiques des offres | Monstage"
    end

    test 'GET #index as statistician success ' \
         'when department params match his departement_name' do
      statistician = create(:prefecture_statistician)
      department_name = statistician.department_name # Oise
      offer = create(:weekly_internship_offer, department: department_name)
      sign_in(statistician)

      get reporting_internship_offers_path(department: department_name, is_public: false)
      assert_response :success
      total_report = retrieve_html_value('test-total-report','test-total-applications', response)
      assert_equal 0, total_report.to_i

      Reporting::InternshipOffer.stub :by_department, Reporting::InternshipOffer.where(discarded_at: nil) do
        get reporting_internship_offers_path(department: 'Oise')
        assert_response :success
        # TODO : check why this is not working
        # assert_equal 2, retrieve_html_value('test-total-report','test-total-applications', response)
        # assert_equal 4, retrieve_html_value('test-total-applications', 'test-total-male-applications', response)
        # assert_equal 3, retrieve_html_value('test-total-male-applications', 'test-total-female-applications', response)
        # assert_equal 1, retrieve_html_value('test-total-female-applications','test-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-total-no-gender-applications','test-approved-applications', response)
        # assert_equal 1, retrieve_html_value('test-male-approved-applications', 'test-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-female-approved-applications', 'test-male-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-no-gender-approved-applications', 'test-male-approved-applications', response)

        get reporting_internship_offers_path(department: department_name, dimension: 'group')
        assert_response :success
        # assert_equal 1, retrieve_html_value('test-total-report','test-total-applications', response)
        # assert_equal 3, retrieve_html_value('test-total-applications', 'test-total-male-applications', response)
        # assert_equal 2, retrieve_html_value('test-total-male-applications', 'test-total-female-applications', response)
        # assert_equal 1, retrieve_html_value('test-total-female-applications','test-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-total-no-gender-applications','test-approved-applications', response)
        # assert_equal 1, retrieve_html_value('test-male-approved-applications', 'test-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-female-approved-applications', 'test-male-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-no-gender-approved-applications', 'test-male-approved-applications', response)
        # null
        assert_equal 0, retrieve_html_value('test-total-report-null','test-total-applications', response)
        assert_equal 0, retrieve_html_value('test-total-applications-null', 'test-total-male-applications', response)
        assert_equal 0, retrieve_html_value('test-total-male-applications-null', 'test-total-female-applications', response)
        assert_equal 0, retrieve_html_value('test-total-female-applications-null','test-approved-applications', response)
        assert_equal 0, retrieve_html_value('test-approved-applications-null','test-custom-track-approved-applications', response)
        assert_equal 0, retrieve_html_value('test-male-approved-applications-null', 'test-approved-applications', response)
        assert_equal 0, retrieve_html_value('test-female-approved-applications-null', 'test-male-approved-applications', response)
        assert_equal 0, retrieve_html_value('test-no-gender-approved-applications-null', 'test-male-approved-applications', response)

        get reporting_internship_offers_path(department: department_name, is_public: true, dimension: 'group')
        assert_response :success
        # assert_equal 1, retrieve_html_value('test-total-report','test-total-applications', response)
        # assert_equal 3, retrieve_html_value('test-total-applications', 'test-total-male-applications', response)
        # assert_equal 2, retrieve_html_value('test-total-male-applications', 'test-total-female-applications', response)
        # assert_equal 1, retrieve_html_value('test-total-female-applications','test-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-total-no-gender-applications','test-approved-applications', response)
        # assert_equal 1, retrieve_html_value('test-male-approved-applications', 'test-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-female-approved-applications', 'test-male-approved-applications', response)
        # assert_equal 0, retrieve_html_value('test-no-gender-approved-applications', 'test-male-approved-applications', response)
        assert_select('test-total-report-null', false)
        assert_select('test-total-applications-null', false)
        assert_select('test-total-male-applications-null', false)
        assert_select('test-total-female-applications-null', false)
        assert_select('test-total-no-gender-applications-null', false)
        assert_select('test-approved-applications-null', false)
        assert_select('test-male-approved-applications-null', false)
        assert_select('test-female-approved-applications-null', false)
        assert_select('test-no-gender-approved-applications-null', false)
      end
    end

    test 'GET #index.xlsx as statistician success ' \
         'when department params match his departement_name' do
      god = create(:god)
      create(:weekly_internship_offer)
      create(:api_internship_offer)
      sign_in(god)

      {
        group: :index_stats,
        sector: :index_stats
      }.each_pair do |dimension, template|
        get(reporting_internship_offers_path(dimension: dimension,
                                             school_year: Date.today.year,
                                             format: :xlsx))
        assert_response :success
        assert_template template
      end
    end

    test 'GET call async Job as god success ' \
         'when department params match his departement_name' do
      god = create(:god)
      create(:weekly_internship_offer)
      create(:api_internship_offer)
      sign_in(god)

      get(reporting_internship_offers_path(dimension: 'offers',
                                           format: :xlsx,
                                           school_year: 2019,
                                           department: 'Paris'))
      assert_response 302
      assert_redirected_to reporting_dashboards_path(department: 'Paris', school_year: 2019)
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_internship_offers_path(department: 'Ain')
      assert_response 302
    end


    test 'GET #index as operator works' do
      user_operator = create(:user_operator)
      sign_in(user_operator)
      get reporting_internship_offers_path(department: 'Ain')
      assert_response 200
    end

    # This helper method retrieves the figures in front of class1,
    # class2 being just a delimiter
    def retrieve_html_value(class1, class2, response)
      regex = Regexp.new("#{class1}\">(.*)</td>.*#{class2}")
      assert_match(regex, response.body)
      response.body.match(regex).captures.first.to_i
    end
  end
end
