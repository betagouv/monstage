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
      @internship_offer_agri_1 = create(:weekly_internship_offer,
                                        sector: @sector_agri,
                                        max_candidates: 1)
      @internship_offer_agri_2 = create(:weekly_internship_offer,
                                        sector: @sector_agri,
                                        max_candidates: 1)
      @internship_offer_wood = create(:weekly_internship_offer,
                                      sector: @sector_wood,
                                      max_candidates: 10)
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
      statistician = create(:statistician)
      department = statistician.department # Oise
      create(:weekly_internship_offer, department: department)
      sign_in(statistician)

      get reporting_internship_offers_path(department: department)
      assert_response :success
      total_report = retrieve_html_value('test-total-report','test-total-applications', response)
      assert_equal 0, total_report.to_i

      Reporting::InternshipOffer.stub :by_department, Reporting::InternshipOffer.all do
        get reporting_internship_offers_path(department: department)
        assert_response :success
        assert_equal 2, retrieve_html_value('test-total-report','test-total-applications', response)
        assert_equal 4, retrieve_html_value('test-total-applications', 'test-total-male-applications', response)
        assert_equal 3, retrieve_html_value('test-total-male-applications', 'test-total-female-applications', response)
        assert_equal 1, retrieve_html_value('test-total-female-applications','test-approved-applications', response)
        assert_equal 1, retrieve_html_value('test-approved-applications','test-custom-track-approved-applications', response)
        assert_equal 1, retrieve_html_value('test-male-approved-applications', 'test-approved-applications', response)
        assert_equal 0, retrieve_html_value('test-female-approved-applications', 'test-male-approved-applications', response)
      end
    end

    test 'GET #index.xlsx as statistician success ' \
         'when department params match his departement_name' do
      god = create(:god)
      create(:weekly_internship_offer)
      create(:api_internship_offer)
      sign_in(god)

      %i[offers group].each do |dimension|
        get(reporting_internship_offers_path(dimension: dimension,
                                             format: :xlsx))
        assert_response :success
      end
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_internship_offers_path(department: 'Ain')
      assert_response 302
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
