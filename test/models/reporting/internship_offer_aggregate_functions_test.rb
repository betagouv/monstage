# frozen_string_literal: true

require 'test_helper'
module Reporting
  class InternshipOfferAggregateFunctionsTest < ActiveSupport::TestCase
    setup do
      @sector_agri = create(:sector, name: 'Agriculture')
      @sector_wood = create(:sector, name: 'Filière bois')
      weeks = [::Week.first, ::Week.last]
      @internship_offer_agri_1 = create(:weekly_internship_offer, weeks: weeks, sector: @sector_agri, max_candidates: 1)
      @internship_offer_agri_2 = create(:weekly_internship_offer, weeks: weeks, sector: @sector_agri, max_candidates: 1)
      @internship_offer_wood = create(:weekly_internship_offer, weeks: weeks, sector: @sector_wood, max_candidates: 10)
    end

    test '.group_by(:sector_name)' do
      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal agri_stats.sector_name, @sector_agri.name
      assert_equal wood_stats.sector_name, @sector_wood.name
    end

    test 'computes internship_offer count by sector' do
      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal 2, agri_stats.total_report_count
      assert_equal 10, wood_stats.total_report_count
    end

    test 'computes internship_offer total_applications_count' do
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1)
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1)
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_2)
      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal 3, agri_stats.total_applications_count
      assert_equal 0, wood_stats.total_applications_count
    end

    test 'computes internship_offer total_male_applications_count' do
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1,
                                                         student: create(:student, :male))
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1,
                                                         student: create(:student, :female))
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_2,
                                                         student: create(:student, :male))
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_wood,
                                                         student: create(:student, :male))

      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal 2, agri_stats.total_male_applications_count
      assert_equal 1, wood_stats.total_male_applications_count
    end

    test 'computes internship_offer total_female_applications_count' do
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1,
                                                         student: create(:student, :male))
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_1,
                                                         student: create(:student, :female))
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_agri_2,
                                                         student: create(:student, :male))
      create(:weekly_internship_application, :submitted, internship_offer: @internship_offer_wood,
                                                         student: create(:student, :male))
      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal 1, agri_stats.total_female_applications_count
      assert_equal 0, wood_stats.total_female_applications_count
    end

    test 'computes internship_offer approved_applications_count' do
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_1)
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_1)
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_2)
      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal 3, agri_stats.approved_applications_count
      assert_equal 0, wood_stats.approved_applications_count
    end

    test 'computes internship_offer total_male_approved_applications_count' do
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :male))
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :female))
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_2,
             student: create(:student, :male))
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_wood,
             student: create(:student, :male))

      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal 2, agri_stats.total_male_approved_applications_count
      assert_equal 1, wood_stats.total_male_approved_applications_count
    end

    test 'computes internship_offer total_female_approved_applications_count' do
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :male))
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_1,
             student: create(:student, :female))
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_agri_2,
             student: create(:student, :male))
      create(:weekly_internship_application, :approved,
             internship_offer: @internship_offer_wood,
             student: create(:student, :male))

      agri_stats, wood_stats = Reporting::InternshipOffer.dimension_by_sector

      assert_equal 1, agri_stats.total_female_approved_applications_count
      assert_equal 0, wood_stats.total_female_approved_applications_count
    end
  end
end
