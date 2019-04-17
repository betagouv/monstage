require 'test_helper'
module Reporting
  class InternshipOfferTest < ActiveSupport::TestCase
    test 'views can be queried' do
      create(:internship_offer)
      create(:internship_offer)
      create(:internship_offer)
      assert_equal 3, Reporting::InternshipOffer.count
    end

    test 'views items support required attributes for reporting' do
      create(:internship_offer)
      internship_offer_reportable = Reporting::InternshipOffer.first
      attribute_names = internship_offer_reportable.attribute_names
      assert_includes attribute_names, "title"
      assert_includes attribute_names, "sector_name"
      assert_includes attribute_names, "employer_departement"
      assert_includes attribute_names, "publicy"
      assert_includes attribute_names, "publicy"
      assert_includes attribute_names, "blocked_weeks_count"
      assert_includes attribute_names, "total_applications_count"
      assert_includes attribute_names, "convention_signed_applications_count"
      assert_includes attribute_names, "approved_applications_count"
    end
  end
end
