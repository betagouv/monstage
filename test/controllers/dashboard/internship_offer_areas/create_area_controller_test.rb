require 'test_helper'

module Dashboard
  module InternshipOfferAreas
    class CreateAreaControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers
      include TeamAndAreasHelper

      test 'POST create_area when employer is alone' do
        employer = create(:employer)
        assert_equal 1, employer.internship_offer_areas.count

        sign_in(employer)
        assert_difference 'InternshipOfferArea.count', 1 do
          post(
            dashboard_internship_offer_areas_path,
            params: { internship_offer_area: { name: 'Nantes' } }
          )
        end
        area = InternshipOfferArea.last
        assert_equal "Nantes", area.name
        assert_equal employer, area.employer
        assert_equal "User", area.employer_type
        assert_redirected_to dashboard_internship_offer_areas_path
      end

      test 'POST create_area when employer is in a team' do
        employer_1 = create(:employer)
        employer_2 = create(:employer)
        create_team(employer_1, employer_2)

        assert_equal 2, employer_1.internship_offer_areas.count

        sign_in(employer_1)
        assert_difference 'InternshipOfferArea.count', 1 do
          post(
            dashboard_internship_offer_areas_path,
            params: { internship_offer_area: { name: 'Nantes' } }
          )
        end
        area = InternshipOfferArea.last
        assert_equal "Nantes", area.name
        assert_equal employer_1, area.employer
        assert_equal "User", area.employer_type
        assert_redirected_to edit_dashboard_internship_offer_area_path(area)
      end
    end
  end
end
