# frozen_string_literal: true

require 'test_helper'

module Finders
  class ReportingInternshipOfferTest < ActiveSupport::TestCase
    test '.total with department params filters offers by departement' do
      finder = ReportingInternshipOffer.new(params: { department: 'Aisne' })
      assert_equal(0,
                   finder.total,
                   'should not find not offers by departement when no one had been')

      create(:internship_offer, zipcode: '02150')
      create(:internship_offer, zipcode: '02150')
      assert_equal(2,
                   finder.total,
                   'bad count of filtered offer by departement')
    end

    test '.total with dimension params group offers' do
      create(:internship_offer, group: nil)
      finder = ReportingInternshipOffer.new(params: { dimension: :group })
      assert_equal(1,
                   finder.total,
                   'should find offers with no group (labeled as independant)')

      public_group = create(:group, is_public: true)
      create(:internship_offer, group: public_group)
      assert_equal(2,
                   finder.total,
                   'should find offers with group')
    end

    test '.total with dimension sector group offers by sector' do
      finder = ReportingInternshipOffer.new(params: { dimension: :sector })
      sector = create(:sector)
      create(:internship_offer, sector: sector)
      assert_equal(1,
                   finder.total,
                   'should find offers with sector')
    end

    test '.total with academy params filters offers by school.academy' do
      academy_key_departements_values = Academy::MAP.first
      academy_name, departements = *academy_key_departements_values
      zipcode = departements.first.ljust(5, '000')
      create(:internship_offer, zipcode: '60000')
      finder = ReportingInternshipOffer.new(params: { academy: academy_name })
      assert_equal(0,
                   finder.total,
                   'should not find offers not in academy')
      create(:internship_offer, zipcode: zipcode)
      assert_equal(1,
                   finder.total,
                   'should not find offers not in academy')
    end

    test '.total with is_public params filters offers by public' do
      private_group = create(:group, is_public: false)
      public_group = create(:group, is_public: true)
      offer = create(:internship_offer, is_public: public_group.is_public, group: public_group)
      finder = ReportingInternshipOffer.new(params: { is_public: private_group.is_public })
      assert_equal(0,
                   finder.total,
                   'should not find offers in a public group')
      create(:internship_offer, is_public: private_group.is_public, group: private_group)
      assert_equal(1,
                   finder.total,
                   'should find offers in a private group')
    end

    test '.total with school_year params filters offers by year' do
      offer_2018 = create(:internship_offer, weeks: [Week.find_by(year: 2019, number: 1)])
      offer_2020 = create(:internship_offer, weeks: [Week.find_by(year: 2021, number: 1)])
      finder = ReportingInternshipOffer.new(params: { school_year: 2018 })
      assert_equal 1, finder.total
      finder = ReportingInternshipOffer.new(params: { school_year: 2019 })
      assert_equal 0, finder.total
      finder = ReportingInternshipOffer.new(params: { school_year: 2020 })
      assert_equal 1, finder.total
      finder = ReportingInternshipOffer.new(params: { school_year: 2021 })
      assert_equal 0, finder.total
    end
  end
end
