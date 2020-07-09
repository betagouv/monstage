# frozen_string_literal: true

require 'test_helper'
module Reporting
  class InternshipOfferAggregateFunctionsTest < ActiveSupport::TestCase
    setup do

      @sector_agri = create(:sector, name: 'Agriculture')
      @sector_wood = create(:sector, name: 'Filière bois')
      weeks = [::Week.first, ::Week.last]
      @internship_offer_agri_1 = create(:internship_offer, weeks: weeks, sector: @sector_agri, max_candidates: 1)
      @internship_offer_agri_2 = create(:internship_offer, weeks: weeks, sector: @sector_agri, max_candidates: 1)
      @internship_offer_wood = create(:internship_offer, weeks: weeks, sector: @sector_wood, max_candidates: 10)
    end

    test '.group_by(:sector_name)' do
      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]

      assert_equal agri_stats.sector_name, @sector_agri.name
      assert_equal wood_stats.sector_name, @sector_wood.name
    end

    test 'computes internship_offer count by sector' do
      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]
      assert_equal 2, agri_stats.total_report_count
      assert_equal 10, wood_stats.total_report_count
    end

    test 'computes internship_offer total_applications_count' do
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_1)
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_1)
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_2)
      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]

      assert_equal 3, agri_stats.total_applications_count
      assert_equal 0, wood_stats.total_applications_count
    end

    test 'computes internship_offer total_male_applications_count' do
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_1,
                                                  student: create(:student, :male))
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_1,
                                                  student: create(:student, :female))
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_2,
                                                  student: create(:student, :male))
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_wood,
                                                  student: create(:student, :male))
      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]

      assert_equal 2, agri_stats.total_male_applications_count
      assert_equal 1, wood_stats.total_male_applications_count
    end

    test 'computes internship_offer total_female_applications_count' do
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_1,
                                                  student: create(:student, :male))
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_1,
                                                  student: create(:student, :female))
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_agri_2,
                                                  student: create(:student, :male))
      create(:internship_application, :weekly, :submitted, internship_offer: @internship_offer_wood,
                                                  student: create(:student, :male))
      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]

      assert_equal 1, agri_stats.total_female_applications_count
      assert_equal 0, wood_stats.total_female_applications_count
    end

    test 'computes internship_offer approved_applications_count' do
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_1)
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_1)
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_2)
      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]

      assert_equal 3, agri_stats.approved_applications_count
      assert_equal 0, wood_stats.approved_applications_count
    end

    test 'computes internship_offer total_male_approved_applications_count' do
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :male))
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :female))
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_2,
             student: create(:student, :male))
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_wood,
             student: create(:student, :male))

      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]

      assert_equal 2, agri_stats.total_male_approved_applications_count
      assert_equal 1, wood_stats.total_male_approved_applications_count
    end

    test 'computes internship_offer total_female_approved_applications_count' do
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :male))
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :female))
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_agri_2,
             student: create(:student, :male))
      create(:internship_application, :weekly, :approved,
             internship_offer: @internship_offer_wood,
             student: create(:student, :male))

      results = Reporting::InternshipOffer.dimension_by_sector
      agri_stats = results[0]
      wood_stats = results[1]

      assert_equal 1, agri_stats.total_female_approved_applications_count
      assert_equal 0, wood_stats.total_female_approved_applications_count
    end
  end
end
