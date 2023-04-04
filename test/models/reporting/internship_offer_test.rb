# frozen_string_literal: true

require 'test_helper'

class ReportingInternshipOfferTest < ActiveSupport::TestCase
  test 'views can be queried' do
    3.times { create(:internship_offer) }
    assert_equal 3, Reporting::InternshipOffer.count
  end

  test 'scopes that select offers depending on years' do
    offer_2018 = create(:internship_offer, weeks: [Week.find_by(year: 2019, number: 1)])
    offer_2020 = create(:internship_offer, weeks: [Week.find_by(year: 2021, number: 1)])

    assert_equal 1, Reporting::InternshipOffer.during_year(school_year: SchoolYear::Floating.new_by_year(year: 2018))
                                              .count
    assert_equal 0, Reporting::InternshipOffer.during_year(school_year: SchoolYear::Floating.new_by_year(year: 2019))
                                              .count
  end

  test '.dimension_by_sector group by sector_name' do
    sector_a = create(:sector, name: 'Agriculture')
    sector_b = create(:sector, name: 'Filière bois')
    2.times { create(:internship_offer, sector: sector_a )}
    create(:internship_offer, sector: sector_b)

    results = Reporting::InternshipOffer.dimension_by_sector
    first_sectored_report = results[0]
    last_sectored_report = results[1]

    assert_equal first_sectored_report.sector_name, sector_a.name
    assert_equal last_sectored_report.sector_name, sector_b.name
  end

  test '.dimension_by_sector sum max_candidates' do
    sector_a = create(:sector, name: 'Agriculture')
    sector_b = create(:sector, name: 'Filière bois')
    create(:internship_offer,
           weeks: [Week.first],
           sector: sector_a,
           max_candidates: 3,
           max_students_per_group: 3)
    create(:internship_offer,
           weeks: [Week.first, Week.last],
           sector: sector_a,
           max_candidates: 1,
           max_students_per_group: 1)
    create(:internship_offer,
           weeks: [Week.first, Week.last],
           sector: sector_b,
           max_candidates: 10,
           max_students_per_group: 10)

    results = Reporting::InternshipOffer.dimension_by_sector
    first_sectored_report = results[0]
    last_sectored_report = results[1]

    assert_equal 4, first_sectored_report.total_report_count
    assert_equal 10, last_sectored_report.total_report_count
  end
end
