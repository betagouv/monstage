require 'test_helper'
module Reporting
  class InternshipOfferTest < ActiveSupport::TestCase
    test 'views can be queried' do
      create(:internship_offer)
      create(:internship_offer)
      create(:internship_offer)
      Reporting::InternshipOffer.refresh
      assert_equal 3, Reporting::InternshipOffer.count
    end

    test 'views items support required attributes for reporting' do
      create(:internship_offer)
      Reporting::InternshipOffer.refresh
      internship_offer_reportable = Reporting::InternshipOffer.first
      attribute_names = internship_offer_reportable.attribute_names
      assert_includes attribute_names, "title"
      assert_includes attribute_names, "zipcode"
      assert_includes attribute_names, "department_name"
      assert_includes attribute_names, "department_code"
      assert_includes attribute_names, "region"
      assert_includes attribute_names, "academy"
      assert_includes attribute_names, "publicly_name"
      assert_includes attribute_names, "publicly_code"
      assert_includes attribute_names, "sector_name"
      assert_includes attribute_names, "blocked_weeks_count"
      assert_includes attribute_names, "total_applications_count"
      assert_includes attribute_names, "convention_signed_applications_count"
      assert_includes attribute_names, "approved_applications_count"
    end

    test "scopes that select offers depending on years" do
      travel_to(Date.new(2019, 5, 15)) do
        create(:internship_offer)
        Reporting::InternshipOffer.refresh
        assert_equal 1, Reporting::InternshipOffer.during_current_year.count
        assert_equal 1, Reporting::InternshipOffer.during_year(year: 2018).count
        assert_equal 0, Reporting::InternshipOffer.during_year(year: 2019).count
      end
    end

    test ".grouped_by_sector group by sector_name" do
      sector_a = create(:sector, name: "Agriculture")
      sector_b = create(:sector, name: "Filière bois")
      create(:internship_offer, sector: sector_a)
      create(:internship_offer, sector: sector_a)
      create(:internship_offer, sector: sector_b)
      Reporting::InternshipOffer.refresh
      results = Reporting::InternshipOffer.grouped_by_sector
      first_sectored_report = results[0]
      last_sectored_report = results[1]

      assert_equal first_sectored_report.report_row_title, sector_a.name
      assert_equal last_sectored_report.report_row_title, sector_b.name
    end

    test ".grouped_by_publicy group by publicly_name" do
      create(:internship_offer, is_public: true)
      create(:internship_offer, is_public: false)
      create(:internship_offer, is_public: true)

      Reporting::InternshipOffer.refresh
      results = Reporting::InternshipOffer.grouped_by_publicy
      publicly_no = results[0]
      publicly_yes = results[1]

      assert_equal publicly_yes.report_row_title, "Secteur Public"
      assert_equal publicly_no.report_row_title, "Secteur Privé"
    end
  end
end

