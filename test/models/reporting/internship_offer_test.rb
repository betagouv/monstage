require 'test_helper'
module Reporting
  class InternshipOfferTest < ActiveSupport::TestCase
    test 'views can be queried' do
      create(:internship_offer)
      create(:internship_offer)
      create(:internship_offer)
      assert_equal 3, Reporting::InternshipOffer.count
    end

    test "scopes that select offers depending on years" do
      travel_to(Date.new(2019, 5, 15)) do
        create(:internship_offer)

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

      results = Reporting::InternshipOffer.grouped_by_sector
      first_sectored_report = results[0]
      last_sectored_report = results[1]

      assert_equal first_sectored_report.sector_name, sector_a.name
      assert_equal last_sectored_report.sector_name, sector_b.name
    end

    test ".grouped_by_publicy group by publicly_name" do
      create(:internship_offer, is_public: true)
      create(:internship_offer, is_public: false, group_name: '')
      create(:internship_offer, is_public: true)


      results = Reporting::InternshipOffer.grouped_by_publicy
      publicly_no = results[0]
      publicly_yes = results[1]

      assert_equal publicly_yes.is_public, true
      assert_equal publicly_no.is_public, false
    end
  end
end

