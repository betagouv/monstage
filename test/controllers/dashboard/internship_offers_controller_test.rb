require 'test_helper'

module Dashboard
  class SchoolsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    #
    # navigation checks
    #
    test 'GET #show as employer displays internship_applications link' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      get dashboard_internship_offer_path(internship_offer)
      assert_select "a[href=?]", dashboard_internship_offer_internship_applications_path(internship_offer),
                                 text: "0 candidatures",
                                 count: 1
    end
  end
end
